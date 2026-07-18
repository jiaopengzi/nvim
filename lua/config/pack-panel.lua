-- FilePath    : nvim\lua\config\pack-panel.lua
-- Description : vim.pack 插件状态面板, 支持查看版本和更新指定插件。

local M = {}

local PANEL_FILETYPE = "jnvim-pack-panel"
local PANEL_TITLE = "插件状态"
local state = {
    buf = nil,
    win = nil,
    line_to_plugin = {},
}

---返回当前面板缓冲区编号, 便于外部验证与调试。
---@return integer|nil
function M.bufnr()
    return state.buf
end

---判断缓冲区是否仍然有效。
---@param buf integer|nil 缓冲区编号。
---@return boolean
local function is_valid_buf(buf)
    return type(buf) == "number" and buf > 0 and vim.api.nvim_buf_is_valid(buf)
end

---判断窗口是否仍然有效。
---@param win integer|nil 窗口编号。
---@return boolean
local function is_valid_win(win)
    return type(win) == "number" and win > 0 and vim.api.nvim_win_is_valid(win)
end

---返回面板展示宽度。
---@return integer
local function panel_width()
    return math.min(math.max(math.floor(vim.o.columns * 0.78), 88), 120)
end

---返回面板展示高度。
---@return integer
local function panel_height()
    return math.min(math.max(math.floor(vim.o.lines * 0.72), 16), 26)
end

---把版本号或 commit hash 缩短为适合面板展示的文本。
---@param revision string|nil 版本或 revision 文本。
---@return string
local function short_rev(revision)
    if type(revision) ~= "string" or revision == "" then
        return "-"
    end
    if #revision <= 10 then
        return revision
    end
    return revision:sub(1, 10)
end

---把 revision 描述成更适合用户阅读的版本文本。
---@param path string|nil 插件本地路径。
---@param revision string|nil revision 文本。
---@return string
local function describe_revision(path, revision)
    if type(path) ~= "string" or path == "" then
        return short_rev(revision)
    end
    if type(revision) ~= "string" or revision == "" then
        return "-"
    end

    local result = vim.system({ "git", "describe", "--tags", "--always", revision }, {
        cwd = path,
        text = true,
    }):wait()

    if result.code ~= 0 then
        return short_rev(revision)
    end

    local value = vim.trim(result.stdout or "")
    if value == "" then
        return short_rev(revision)
    end

    return value
end

---格式化当前版本列, 同时保留版本约束信息。
---@param item table vim.pack.get 返回的单项数据。
---@return string
local function format_current(item)
    local tracked = item.spec and item.spec.version
    local current = describe_revision(item.path, item.rev)
    if type(tracked) == "string" and tracked ~= "" then
        return current .. " (" .. tracked .. ")"
    end
    return current
end

---格式化目标版本列。
---@param item table vim.pack.get 返回的单项数据。
---@return string
local function format_target(item)
    if item.rev_to == nil or item.rev_to == item.rev then
        return "-"
    end

    return describe_revision(item.path, item.rev_to)
end

---把文本裁剪并填充到固定宽度。
---@param text string 原始文本。
---@param width integer 列宽。
---@return string
local function fit_cell(text, width)
    local value = tostring(text or "-"):gsub("\n", " ")
    if vim.fn.strdisplaywidth(value) > width then
        value = value:sub(1, math.max(1, width - 1)) .. "…"
    end
    return value .. string.rep(" ", math.max(0, width - vim.fn.strdisplaywidth(value)))
end

---返回当前浮动面板窗口配置。
---@return table
local function float_config()
    local width = panel_width()
    local height = panel_height()

    return {
        relative = "editor",
        style = "minimal",
        border = "rounded",
        title = " " .. PANEL_TITLE .. " ",
        title_pos = "center",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2) - 1,
        col = math.floor((vim.o.columns - width) / 2),
    }
end

---关闭当前状态面板。
---@return nil
local function close_panel()
    if is_valid_win(state.win) then
        vim.api.nvim_win_close(state.win, true)
    end
    state.win = nil
    state.buf = nil
    state.line_to_plugin = {}
end

---为面板缓冲区设置基础选项。
---@param buf integer 缓冲区编号。
---@return nil
local function configure_buffer(buf)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = PANEL_FILETYPE
    vim.bo[buf].buflisted = false
end

---为面板窗口设置基础选项。
---@param win integer 窗口编号。
---@return nil
local function configure_window(win)
    vim.wo[win].cursorline = true
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = "no"
    vim.wo[win].foldcolumn = "0"
    vim.wo[win].spell = false
    vim.wo[win].wrap = false
end

---确保状态面板窗口存在, 不存在时重新创建。
---@return integer, integer
local function ensure_panel_window()
    if not is_valid_buf(state.buf) then
        state.buf = vim.api.nvim_create_buf(false, true)
        configure_buffer(state.buf)
    end

    if not is_valid_win(state.win) then
        state.win = vim.api.nvim_open_win(state.buf, true, float_config())
        configure_window(state.win)
    else
        vim.api.nvim_set_current_win(state.win)
    end

    return state.buf, state.win
end

---清空并写入面板内容。
---@param lines string[] 要写入的完整行列表。
---@return nil
local function set_panel_lines(lines)
    if not is_valid_buf(state.buf) then
        return
    end

    vim.bo[state.buf].modifiable = true
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
    vim.bo[state.buf].modifiable = false
end

---根据当前插件状态渲染面板。
---@param items table[] 插件状态列表。
---@param summary string|nil 顶部摘要信息。
---@return nil
local function render_items(items, summary)
    local lines = {
        "q 关闭 | r 刷新 | u 升级当前插件 | U 升级全部插件",
        summary or "提示: Current 列显示当前锁定约束或 revision 缩写, Target 列显示可更新到的 revision.",
        "",
    }

    local widths = {
        name = 28,
        current = 24,
        update = 8,
        target = 24,
    }

    table.insert(
        lines,
        fit_cell("Plugin", widths.name)
        .. " "
        .. fit_cell("Current", widths.current)
        .. " "
        .. fit_cell("Update", widths.update)
        .. " "
        .. fit_cell("Target", widths.target)
    )
    table.insert(lines, string.rep("-", panel_width() - 4))

    state.line_to_plugin = {}

    for _, item in ipairs(items) do
        local has_update = item.rev_to ~= nil and item.rev_to ~= item.rev
        local line = fit_cell(item.spec.name, widths.name)
            .. " "
            .. fit_cell(format_current(item), widths.current)
            .. " "
            .. fit_cell(has_update and "yes" or "no", widths.update)
            .. " "
            .. fit_cell(format_target(item), widths.target)

        table.insert(lines, line)
        state.line_to_plugin[#lines] = item.spec.name
    end

    if #items == 0 then
        table.insert(lines, "当前没有受 vim.pack 管理的插件.")
    end

    set_panel_lines(lines)

    if not is_valid_buf(state.buf) then
        return
    end

    vim.api.nvim_buf_clear_namespace(state.buf, -1, 0, -1)
    vim.api.nvim_buf_add_highlight(state.buf, -1, "Title", 0, 0, -1)
    vim.api.nvim_buf_add_highlight(state.buf, -1, "Comment", 1, 0, -1)
    vim.api.nvim_buf_add_highlight(state.buf, -1, "Identifier", 3, 0, -1)
    vim.api.nvim_buf_add_highlight(state.buf, -1, "Comment", 4, 0, -1)

    for line_nr, plugin_name in pairs(state.line_to_plugin) do
        local has_update = false
        for _, item in ipairs(items) do
            if item.spec.name == plugin_name then
                has_update = item.rev_to ~= nil and item.rev_to ~= item.rev
                break
            end
        end

        if has_update then
            vim.api.nvim_buf_add_highlight(state.buf, -1, "DiagnosticWarn", line_nr - 1, 0, -1)
        end
    end
end

---渲染加载中提示。
---@param message string 提示信息。
---@return nil
local function render_loading(message)
    set_panel_lines({
        "q 关闭 | r 刷新 | u 升级当前插件 | U 升级全部插件",
        message,
    })
end

---渲染错误提示。
---@param err string 错误信息。
---@return nil
local function render_error(err)
    set_panel_lines({
        "q 关闭 | r 刷新 | u 升级当前插件 | U 升级全部插件",
        "读取插件状态失败: " .. tostring(err),
    })
end

---返回光标所在行对应的插件名。
---@return string|nil
local function current_plugin_name()
    if not is_valid_win(state.win) then
        return nil
    end

    local cursor = vim.api.nvim_win_get_cursor(state.win)
    return state.line_to_plugin[cursor[1]]
end

---刷新插件状态面板。
---@param offline boolean|nil 是否跳过远端检查。
---@return nil
local function refresh_panel(offline)
    ensure_panel_window()
    render_loading("正在检查插件状态, 请稍候...")

    vim.schedule(function()
        local items, err = require("config.pack").get_plugin_statuses(offline)
        if not items then
            render_error(err or "未知错误")
            return
        end

        local update_count = 0
        for _, item in ipairs(items) do
            if item.rev_to ~= nil and item.rev_to ~= item.rev then
                update_count = update_count + 1
            end
        end

        render_items(items, string.format("共 %d 个插件, %d 个可更新.", #items, update_count))
    end)
end

---更新当前光标所在行的插件。
---@return nil
local function update_current_plugin()
    local plugin_name = current_plugin_name()
    if not plugin_name then
        vim.notify("请先把光标移动到插件行后再升级指定插件.", vim.log.levels.WARN)
        return
    end

    render_loading("正在升级插件: " .. plugin_name .. " ...")

    vim.schedule(function()
        local ok, err = require("config.pack").update_plugins({ plugin_name })
        if not ok then
            render_error(err or "未知错误")
            return
        end

        refresh_panel(false)
    end)
end

---更新全部插件。
---@return nil
local function update_all_plugins()
    render_loading("正在升级全部插件, 请稍候...")

    vim.schedule(function()
        local ok, err = require("config.pack").update_plugins(nil)
        if not ok then
            render_error(err or "未知错误")
            return
        end

        refresh_panel(false)
    end)
end

---为面板缓冲区注册本地快捷键。
---@param buf integer 缓冲区编号。
---@return nil
local function set_panel_keymaps(buf)
    local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = buf, silent = true, nowait = true, desc = desc })
    end

    map("q", close_panel, "关闭插件状态面板")
    map("<Esc>", close_panel, "关闭插件状态面板")
    map("r", function() refresh_panel(false) end, "刷新插件状态")
    map("u", update_current_plugin, "升级当前插件")
    map("<CR>", update_current_plugin, "升级当前插件")
    map("U", update_all_plugins, "升级全部插件")
end

---打开插件状态面板并立即刷新远端状态。
---@return nil
function M.open()
    local buf = ensure_panel_window()
    set_panel_keymaps(buf)
    refresh_panel(false)
end

return M
