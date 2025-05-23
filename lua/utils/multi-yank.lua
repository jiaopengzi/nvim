-- FilePath    : nvim\lua\utils\multi-yank.lua
-- Author      : jiaopengzi
-- Blog        : https://jiaopengzi.com
-- Copyright   : Copyright (c) 2025 by jiaopengzi, All Rights Reserved.
-- Description : 多次复制 一次性粘贴

local M = {}

-- 追加复制内容到寄存器 s 待用, 用于多次复制内容后一次性粘贴
function M.append_yank_register()
    -- 1. 将选中内容复制到寄存器 z
    vim.cmd('normal! "zy')

    -- 2. 读取寄存器 z 并在其后拼接换行
    local reg_val = vim.fn.getreg('z') .. "\n"

    -- 3. 读取寄存器 s 的原内容
    local old_val = vim.fn.getreg('s')

    -- 4. 拼接并写回到 s (使用字符模式存放)
    vim.fn.setreg('s', old_val .. reg_val, 'c')
end

-- 将多选的内容粘贴出来
function M.paste_with_multi_selection_register()
    -- 粘贴多选寄存器 @s 内容
    vim.cmd('normal! "sp')
end

-- 清空多选寄存器
function M.clear_multi_selection_register()
    vim.cmd(':let @s=""')
end

return M
