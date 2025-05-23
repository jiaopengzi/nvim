-- FilePath    : nvim\lua\utils\file-header.lua
-- Author      : jiaopengzi
-- Blog        : https://jiaopengzi.com
-- Copyright   : Copyright (c) 2025 by jiaopengzi, All Rights Reserved.
-- Description : 文件头插入 

local M = {}

-- 利用 :echo &filetype 可以查看当前文件的类型, 例如 go, typescript 等, 根据不同类型插入不同的头部
-- 快捷键 <leader>ih
-- 获取当前缓冲文件相对于项目根目录的路径
-- @param include_project_root boolean 是否包含项目根目录
-- @return string
local function get_file_path(include_project_root)
    local absolute_path = vim.fn.expand("%:p") -- 获取当前缓冲区文件的绝对路径
    local project_root  = vim.fn.getcwd()      -- 将当前工作目录视为项目根目录
    local separator     = "/"                  -- 默认分隔符为斜杠

    -- 判断是否为 windows
    -- 使用 vim.loop.os_uname().sysname 系统名称 转换为小写 判断是否包含 windows
    if vim.loop.os_uname().sysname:lower():find("windows") then
        separator = "\\" -- windows 下分隔符为反斜杠
    end

    local project_name  = vim.fn.fnamemodify(project_root, ":t")
    local relative_path = vim.fn.fnamemodify(absolute_path, ":." .. project_root)

    -- 如果 include_project_root 为 true, 则返回项目名称 + 相对路径; 否则返回 ./ + 相对路径
    if include_project_root then
        return project_name .. separator .. relative_path
    else
        return "." .. separator .. relative_path
    end
end

function M.insert_file_header()
    local filetype = vim.bo.filetype
    local author = "jiaopengzi"
    local blog = "https://jiaopengzi.com"
    local year = os.date("%Y", os.time())

    -- 构造行内容
    local row_filepath = "FilePath    : " .. get_file_path(true)
    local row_author = "Author      : " .. author
    local row_blog = "Blog        : " .. blog
    local row_copyright = "Copyright   : Copyright (c) " .. year .. " by " .. author .. ", All Rights Reserved."
    local row_description = "Description : "
    local lines = {}

    if filetype == "go" then
        lines = {
            "//",
            "// " .. row_filepath,
            "// " .. row_author,
            "// " .. row_blog,
            "// " .. row_copyright,
            "// " .. row_description,
            "//",
        }
    elseif filetype == "typescript" or filetype == "javascript" then
        lines = {
            "/*",
            " * " .. row_filepath,
            " * " .. row_author,
            " * " .. row_blog,
            " * " .. row_copyright,
            " * " .. row_description,
            " */",
        }
    elseif filetype == "vue" or filetype == "html" then
        lines = {
            "<!--",
            " * " .. row_filepath,
            " * " .. row_author,
            " * " .. row_blog,
            " * " .. row_copyright,
            " * " .. row_description,
            "-->",
        }
    elseif filetype == "css" or filetype == "scss" or filetype == "sass" or filetype == "less" then
        lines = {
            "/*",
            " * " .. row_filepath,
            " * " .. row_author,
            " * " .. row_blog,
            " * " .. row_copyright,
            " * " .. row_description,
            " */",
        }
    elseif filetype == "lua" then
        lines = {
            "-- " .. row_filepath,
            "-- " .. row_author,
            "-- " .. row_blog,
            "-- " .. row_copyright,
            "-- " .. row_description,
        }
    end

    -- 在第 0 行插入多行内容
    vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
    -- 定位光标到 `@Description :` 的末尾
    -- 计算 `@Description :` 所在行号（第 6 行，从 0 开始）
    local line_num = 5
    -- 获取该行的内容
    local line_content = vim.api.nvim_buf_get_lines(0, line_num, line_num + 1, false)[1]
    -- 计算 `@Description :` 的末尾列号
    local col_num = #line_content

    -- 设置光标位置
    vim.api.nvim_win_set_cursor(0, { line_num + 1, col_num })
end

return M
