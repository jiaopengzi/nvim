-- FilePath    : nvim\lua\utils\single-yank.lua
-- Author      : jiaopengzi
-- Blog        : https://jiaopengzi.com
-- Copyright   : Copyright (c) 2025 by jiaopengzi, All Rights Reserved.
-- Description : 单一复制, 单独复制到z寄存器, 下次粘贴复用

local M = {}

-- 复制到寄存器 z 中待用
function M.yank_to_z_register()
    vim.cmd('normal! "zy')
end

-- 粘贴寄存器 z 中的内容
function M.paste_with_z_register()
    vim.cmd('normal! "zp')
end

return M
