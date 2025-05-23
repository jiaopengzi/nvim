-- FilePath    : nvim\lua\utils\selection.lua
-- Author      : jiaopengzi
-- Blog        : https://jiaopengzi.com
-- Copyright   : Copyright (c) 2025 by jiaopengzi, All Rights Reserved.
-- Description : 获取选区或光标下内容的通用函数

local M = {}

-- 获取选区或光标下内容的通用函数
-- @param delimiter string 分隔符，默认为换行符
-- @return string 选区内容
function M.get_visual_selection_content(delimiter)
    delimiter = delimiter or "\n"

    -- 获取当前模式
    local mode = vim.fn.mode()
    local selected_content = ""

    -- Visual / Visual Line / Visual Block 模式
    if mode == 'v' or mode == 'V' or mode == '\x16' then
        -- 发送 <Esc> 退出 Visual 模式, 需要在普通模式下操作
        vim.cmd([[execute "normal! \<Esc>"]])

        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")
        local start_line, start_col = start_pos[2], start_pos[3]
        local end_line, end_col = end_pos[2], end_pos[3]

        if start_line == end_line then
            -- 选区只在同一行
            local line_text = vim.fn.getline(start_line)
            selected_content = string.sub(line_text, start_col, end_col)
        else
            -- 选区跨行
            local lines = vim.fn.getline(start_line, end_line)
            local n = #lines
            -- 截取首行的选中部分
            lines[1] = string.sub(lines[1], start_col)
            -- 截取末行的选中部分
            lines[n] = string.sub(lines[n], 1, end_col)
            -- 拼接多行文本，使用空格或其它分隔符
            selected_content = table.concat(lines, delimiter)
        end
    else
        -- Normal 模式, 则直接取光标下的单词
        selected_content = vim.fn.expand("<cword>")
    end

    -- 转义 / 和 \ 字符
    return vim.fn.escape(selected_content, '/\\')
end

return M
