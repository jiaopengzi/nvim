-- FilePath    : nvim\lua\config\pack.lua
-- Description : 使用 Neovim 原生 vim.pack 管理插件, 并兼容当前 lazy 风格的插件规格。

local M = {}

local pack_start_hrtime = vim.uv.hrtime()
local loaded_plugins = {}
local all_specs = {}
local load_order = {}

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

---把字符串或数组统一规范成数组。
---@param value string|string[]|nil 原始值。
---@return string[]
local function listify(value)
    if value == nil then
        return {}
    end
    if type(value) == "string" then
        return { value }
    end
    if vim.islist(value) then
        return vim.deepcopy(value)
    end
    return {}
end

---返回插件仓库尾名。
---@param src string 插件仓库地址或 owner/repo 字符串。
---@return string
local function repo_tail(src)
    return src:match("([^/]+)$") or src
end

---推断插件目录名。
---@param spec table 插件规格。
---@return string
local function plugin_name(spec)
    if spec.name and spec.name ~= "" then
        return spec.name
    end

    local tail = repo_tail(spec.src or spec[1])
    tail = tail:gsub("%.git$", "")
    return tail
end

---推断插件默认入口模块名。
---@param spec table 插件规格。
---@return string
local function plugin_main(spec)
    if spec.main and spec.main ~= "" then
        return spec.main
    end

    local name = plugin_name(spec)
    name = name:gsub("%.nvim$", "")
    name = name:gsub("%-nvim$", "")
    name = name:gsub("%.lua$", "")
    return name
end

---把 owner/repo 形式转换成完整 Git 地址。
---@param src string 插件仓库地址或 owner/repo 字符串。
---@return string
local function normalize_src(src)
    if src:match("^[%w+.-]+://") or src:match("^git@") then
        return src
    end
    return "https://github.com/" .. src
end

---规范化单个插件规格。
---@param spec table|string 插件规格。
---@return table
local function normalize_spec(spec)
    if type(spec) == "string" then
        spec = { spec }
    end

    local normalized = vim.deepcopy(spec)
    normalized.src = normalize_src(normalized.src or normalized[1])
    normalized.name = plugin_name(normalized)
    normalized.priority = normalized.priority or 0
    normalized.event = listify(normalized.event)
    normalized.cmd = listify(normalized.cmd)
    normalized.ft = listify(normalized.ft)
    normalized.keys = vim.islist(normalized.keys) and vim.deepcopy(normalized.keys) or {}
    normalized.dependencies = vim.islist(normalized.dependencies) and vim.deepcopy(normalized.dependencies) or {}
    normalized._loaded = false
    normalized._loading = false
    normalized._handlers_registered = false
    return normalized
end

---从目录导入所有插件规格文件。
---@param import_path string import 路径, 例如 plugins.neovim。
---@return table[]
local function collect_import_specs(import_path)
    local import_rel = import_path:gsub("%.", "/")
    local import_dir = vim.fs.joinpath(vim.fn.stdpath("config"), "lua", import_rel)
    local files = {}

    for name, entry_type in vim.fs.dir(import_dir) do
        if entry_type == "file" and name:match("%.lua$") then
            table.insert(files, vim.fs.joinpath(import_dir, name))
        end
    end

    table.sort(files)

    local specs = {}
    for _, file in ipairs(files) do
        local chunk, err = loadfile(file)
        if not chunk then
            vim.notify("加载插件规格失败: " .. file .. "; " .. err, vim.log.levels.ERROR)
        else
            local ok, module_spec = pcall(chunk)
            if ok and module_spec then
                table.insert(specs, module_spec)
            else
                vim.notify("加载插件规格失败: " .. file, vim.log.levels.ERROR)
            end
        end
    end

    return specs
end

---递归展开插件规格中的 import 语法。
---@param raw_specs table[] 根规格列表。
---@return table[]
local function expand_specs(raw_specs)
    local result = {}

    for _, item in ipairs(raw_specs) do
        if item.enabled == false then
            goto continue
        end

        if item.import then
            local imported = collect_import_specs(item.import)
            local expanded = expand_specs(imported)
            vim.list_extend(result, expanded)
        else
            table.insert(result, normalize_spec(item))
        end

        ::continue::
    end

    return result
end

---为键位规格提取真正的右值。
---@param key_spec table 键位规格。
---@return any
local function key_rhs(key_spec)
    if key_spec[2] ~= nil then
        return key_spec[2]
    end
    if key_spec[3] ~= nil then
        return key_spec[3]
    end
    return nil
end

---把键位规格转换成 keymap 参数。
---@param key_spec table 键位规格。
---@return string|string[], string, function|string|nil, table
local function normalize_keymap(key_spec)
    local lhs = key_spec[1]
    local rhs = key_rhs(key_spec)
    local mode = key_spec.mode or "n"
    local opts = {}

    for key, value in pairs(key_spec) do
        if type(key) ~= "number" and key ~= "mode" then
            opts[key] = value
        end
    end

    return mode, lhs, rhs, opts
end

---统一执行插件 setup 或 config 逻辑。
---@param spec table 插件规格。
local function apply_plugin_config(spec)
    local opts = spec.opts
    if type(opts) == "function" then
        opts = opts(spec, nil)
    end

    if spec.config == true then
        require(plugin_main(spec)).setup(opts or {})
        return
    end

    if type(spec.config) == "function" then
        spec.config(spec, opts)
        return
    end

    if opts ~= nil then
        require(plugin_main(spec)).setup(opts)
    end
end

---注册安装或更新后的构建钩子。
---@param spec table 插件规格。
local function register_build_hook(spec)
    if not spec.build or spec._build_hook_registered then
        return
    end

    spec._build_hook_registered = true

    vim.api.nvim_create_autocmd("PackChanged", {
        callback = function(ev)
            if ev.data.spec.name ~= spec.name then
                return
            end
            if ev.data.kind ~= "install" and ev.data.kind ~= "update" then
                return
            end
            if type(spec.build) == "function" then
                spec.build(spec)
                return
            end
            vim.cmd(spec.build)
        end,
    })
end

---加载单个插件及其依赖, 并执行配置。
---@param name string 插件名。
---@return table|nil
local function load_plugin(name)
    local spec = all_specs[name]
    if not spec then
        return nil
    end
    if spec._loaded or spec._loading then
        return spec
    end

    spec._loading = true

    for _, dep in ipairs(spec.dependencies or {}) do
        local dep_name = type(dep) == "table" and plugin_name(dep) or plugin_name({ dep })
        if not all_specs[dep_name] then
            local dep_spec = normalize_spec(type(dep) == "table" and dep or { dep })
            all_specs[dep_name] = dep_spec
        end
        load_plugin(dep_name)
    end

    register_build_hook(spec)
    vim.pack.add({ { src = spec.src, name = spec.name, version = spec.version } }, { confirm = false, load = true })
    apply_plugin_config(spec)

    spec._loading = false
    spec._loaded = true
    loaded_plugins[name] = true
    table.insert(load_order, name)
    return spec
end

---判断插件是否需要启动时立即加载。
---@param spec table 插件规格。
---@return boolean
local function should_load_on_start(spec)
    if spec.lazy == false then
        return true
    end
    return #spec.event == 0 and #spec.cmd == 0 and #spec.ft == 0 and #spec.keys == 0
end

---按命令名懒加载插件, 然后重放原命令。
---@param spec table 插件规格。
---@param cmd_name string 命令名。
---@param cmd_opts table 命令参数。
local function exec_lazy_command(spec, cmd_name, cmd_opts)
    pcall(vim.api.nvim_del_user_command, cmd_name)
    load_plugin(spec.name)

    local parts = { cmd_name }
    if cmd_opts.bang then
        parts[1] = parts[1] .. "!"
    end
    if cmd_opts.args and cmd_opts.args ~= "" then
        table.insert(parts, cmd_opts.args)
    end

    vim.cmd(table.concat(parts, " "))
end

---注册命令懒加载。
---@param spec table 插件规格。
local function register_cmd_handlers(spec)
    for _, cmd_name in ipairs(spec.cmd) do
        vim.api.nvim_create_user_command(cmd_name, function(cmd_opts)
            exec_lazy_command(spec, cmd_name, cmd_opts)
        end, {
            nargs = "*",
            bang = true,
        })
    end
end

---注册事件懒加载。
---@param spec table 插件规格。
local function register_event_handlers(spec)
    for _, event_name in ipairs(spec.event) do
        local event = event_name
        local pattern = nil

        if event_name == "VeryLazy" then
            event = "User"
            pattern = "VeryLazy"
        end

        vim.api.nvim_create_autocmd(event, {
            pattern = pattern,
            once = true,
            callback = function()
                load_plugin(spec.name)
            end,
        })
    end
end

---注册文件类型懒加载。
---@param spec table 插件规格。
local function register_ft_handlers(spec)
    if #spec.ft == 0 then
        return
    end

    vim.api.nvim_create_autocmd("FileType", {
        pattern = spec.ft,
        once = true,
        callback = function()
            load_plugin(spec.name)
        end,
    })
end

---注册键位懒加载, 首次触发时先加载插件再执行原键位逻辑。
---@param spec table 插件规格。
local function register_key_handlers(spec)
    for _, key_spec in ipairs(spec.keys) do
        local mode, lhs, rhs, opts = normalize_keymap(key_spec)
        vim.keymap.set(mode, lhs, function()
            load_plugin(spec.name)
            if type(rhs) == "function" then
                return rhs()
            end
            if type(rhs) == "string" and rhs ~= "" then
                vim.api.nvim_feedkeys(vim.keycode(rhs), "m", false)
            end
        end, opts)
    end
end

---注册单个插件的所有懒加载入口。
---@param spec table 插件规格。
local function register_lazy_handlers(spec)
    if spec._handlers_registered then
        return
    end

    if type(spec.init) == "function" then
        spec.init(spec)
    end

    register_cmd_handlers(spec)
    register_event_handlers(spec)
    register_ft_handlers(spec)
    register_key_handlers(spec)

    spec._handlers_registered = true
end

---按优先级排序插件, 保持启动顺序稳定。
---@param specs table[] 插件规格列表。
---@return table[]
local function sort_specs(specs)
    table.sort(specs, function(a, b)
        if a.priority == b.priority then
            return a.name < b.name
        end
        return a.priority > b.priority
    end)
    return specs
end

---触发与 lazy VeryLazy 近似的用户事件, 兼容现有事件配置。
local function register_verylazy_event()
    vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
            vim.schedule(function()
                vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy", modeline = false })
            end)
        end,
    })
end

---初始化 vim.pack 插件管理。
function M.setup()
    register_verylazy_event()

    local root_specs = require("plugins")
    local specs = sort_specs(expand_specs(root_specs))

    for _, spec in ipairs(specs) do
        all_specs[spec.name] = spec
    end

    for _, spec in ipairs(specs) do
        if should_load_on_start(spec) then
            if type(spec.init) == "function" then
                spec.init(spec)
            end
            load_plugin(spec.name)
        else
            register_lazy_handlers(spec)
        end
    end
end

---返回 dashboard 需要的插件统计信息。
---@return { loaded: integer, count: integer, startuptime: number }
function M.stats()
    local count = 0
    for _ in pairs(all_specs) do
        count = count + 1
    end

    return {
        loaded = #load_order,
        count = count,
        startuptime = (vim.uv.hrtime() - pack_start_hrtime) / 1000000,
    }
end

---查询当前插件状态列表。
---@param offline boolean|nil 是否跳过远端更新检查, 默认 false.
---@return table[]|nil, string|nil
function M.get_plugin_statuses(offline)
    local ok, info = pcall(vim.pack.get, nil, { offline = offline == true })
    if not ok then
        return nil, tostring(info)
    end

    table.sort(info, function(left, right)
        local left_has_update = left.rev_to ~= nil and left.rev_to ~= left.rev
        local right_has_update = right.rev_to ~= nil and right.rev_to ~= right.rev

        if left_has_update ~= right_has_update then
            return left_has_update
        end

        return left.spec.name < right.spec.name
    end)

    return info, nil
end

---按插件名更新指定插件, names 为 nil 时更新全部插件。
---@param names string[]|nil 要更新的插件名列表。
---@return boolean, string|nil
function M.update_plugins(names)
    local ok, err = pcall(vim.pack.update, names, { force = true })
    if not ok then
        return false, tostring(err)
    end

    return true, nil
end

---打开 vim.pack 插件状态面板。
---@return nil
function M.open_panel()
    require("config.pack-panel").open()
end

M.setup()

vim.api.nvim_create_user_command("PackStatus", function()
    M.open_panel()
end, { desc = "显示 vim.pack 插件状态面板" })

return M
