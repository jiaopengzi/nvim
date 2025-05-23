-- FilePath    : nvim\lua\config\autocmds.lua
-- Description : 自动执行

-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local ime = require("utils.ime-switch") -- 输入法切换模块

-- 在复制文本后高亮显示
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        (vim.hl or vim.highlight).on_yank()
    end,
})

-- 在插入模式进入和离开时切换输入法
vim.api.nvim_create_autocmd("InsertLeave", {
    pattern = "*",
    callback = function()
        ime.switch_to_english()
    end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
    pattern = "*",
    callback = function()
        ime.insert_enter()
    end,
})

-- 在搜索模式进入和离开时切换输入法
vim.api.nvim_create_autocmd("CmdlineEnter", {
    pattern = "/,\\?",
    callback = function()
        ime.switch_to_chinese()
    end,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
    pattern = "/,\\?",
    callback = function()
        ime.switch_to_english()
    end,
})
