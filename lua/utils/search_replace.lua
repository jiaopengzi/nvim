-- FilePath    : nvim\lua\utils\search_replace.lua
-- Author      : jiaopengzi
-- Blog        : https://jiaopengzi.com
-- Copyright   : Copyright (c) 2025 by jiaopengzi, All Rights Reserved.
-- Description : 快速搜索当前光标所在的内容

local selection = require("utils.selection")
local vk = require("utils.virtual-keyboard")

local M = {}

-- 搜索选中内容
function M.search_selection_content()
    -- 获取选择的内容
    local selected_content = selection.get_visual_selection_content()
    if selected_content == "" then
        return
    end

    -- 回车
    local cr = vim.api.nvim_replace_termcodes('<CR>', true, false, true)

    -- 构造命令内容
    local cmd = 'normal! /' .. selected_content .. cr

    -- 执行命令
    vim.cmd(cmd)
end

-- 将光标移动到新内容的位置, 等待输入内容
local function cursor_move()
    if vim.g.vscode then
        -- vscode 使用模拟按键的方式, 无法直接使用 feedkeys() 函数
        -- 循环 3 次, 用 <Left> 键将光标移动到第一个斜杠后面
        -- 等待 100ms, 等待输入替换目标
        vim.defer_fn(function()
            for _ = 1, 3 do
                vk.press_key(vk.Key.VK_Left)
            end
        end, 100)
    else
        -- 然后用 <Left> 把光标向左移动 3 次, 停在第二个斜杠后面, 等待输入替换目标
        local left = vim.api.nvim_replace_termcodes("<Left>", true, false, true)
        vim.api.nvim_feedkeys(left .. left .. left, "n", false)
    end
end

-- 替换选中内容
function M.replace_selection_content()
    -- 获取选择的内容
    local selected_content = selection.get_visual_selection_content()
    if selected_content == "" then
        return
    end

    -- 使用 %s, 表示全缓冲区替换；如果想只替换可视选区, 可改为 ":\'<,\'>s/old/new/gc"
    local partial_cmd = string.format(":%%s/%s//gc", selected_content)
    -- feedkeys() 可以在 Normal 模式下模拟输入键盘按键
    vim.api.nvim_feedkeys(partial_cmd, "n", false)

    -- 光标移动, 等待输入内容
    cursor_move()
end

return M
