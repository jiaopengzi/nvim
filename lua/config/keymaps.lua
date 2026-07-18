-- FilePath    : nvim\lua\config\keymaps.lua
-- Author      : jiaopengzi
-- Blog        : https://jiaopengzi.com
-- Copyright   : Copyright (c) 2025 by jiaopengzi, All Rights Reserved.
-- Description : 快捷键

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local file_header = require("utils.file-header")
local multi_yank = require("utils.multi-yank")
local sr = require("utils.search_replace")
local single_yank = require("utils.single-yank")

-- ======================================================================== vscode 快捷键开始
if vim.g.vscode then
    -- 在 n v 模式下 leader lf 会使用 vscode 格式化当前文件
    map(
        { "n", "v" },
        "<leader>lf",
        "<Cmd>lua require('vscode').call('editor.action.formatDocument')<CR>",
        { desc = "格式化文档" }
    )

    map(
        "n",
        "<leader>E",
        "<Cmd>lua require('vscode').call('workbench.action.toggleSidebarVisibility')<CR>",
        { desc = "切换侧边栏的可见性" }
    )

    map(
        "n",
        "<leader>e",
        "<Cmd>lua require('vscode').call('workbench.action.focusSideBar')<CR>",
        { desc = "焦点切换到侧边栏资源管理器" }
    )

    map(
        "n",
        "<leader>at",
        "<Cmd>lua require('vscode').call('workbench.action.toggleActivityBarVisibility')<CR>",
        { desc = "切换活动栏可见性" }
    )

    map(
        "n",
        "<leader>ct",
        "<Cmd>lua require('vscode').call('workbench.action.closeEditorInAllGroups')<CR>",
        { desc = "关闭 tab 标签" }
    )

    map(
        "n",
        "<leader>qv",
        "<Cmd>lua require('vscode').call('workbench.action.closeWindow')<CR>",
        { desc = "退出 vscode 程序" }
    )
end
-- ======================================================================== vscode 快捷键开始

-- ======================================================================== 自定义快捷键开始
map("n", "<leader>q", "<cmd>q<cr>", { desc = "退出当前窗口" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "保存当前更改", remap = true })

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "向下移动选中内容" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "向上移动选中内容" })

map("n", "<leader>h", "<cmd>noh<cr>", { desc = "取消高亮" })

map("n", "<leader>ih", file_header.insert_file_header, { desc = "插入文件头部" })

map("n", "<leader>mm", "mM", { desc = "设置常用全局书签" })
map("n", "<leader>mb", "`M", { desc = "返回常用局部书签" })

-- 多选复制粘贴
map({ "n", "v" }, "<leader>mc", multi_yank.clear_multi_selection_register, { desc = "清空多选寄存器 s" })
map({ "n", "v" }, "<leader>ma", multi_yank.append_yank_register, { desc = "追加复制到多选寄存器 s" })
map({ "n", "v" }, "<leader>mp", multi_yank.paste_with_multi_selection_register, { desc = "粘贴多选寄存器 s 的内容" })

-- 单选复制粘贴
map({ "n", "v" }, "<leader>y", single_yank.yank_to_z_register, { desc = "复制到寄存器 z 中待用" })
map({ "n", "v" }, "<leader>p", single_yank.paste_with_z_register, { desc = "粘贴寄存器 z 的内容" })

-- -- 在 n v i 模式下, 将 ctrl + a 映射为全选
-- map({ "n", "v", "i" }, "<C-a>", "<esc>ggVG", { desc = "全选" })

-- -- 将原来的 ctrl + a 映射改为 leader + a
-- map({ "n", "v" }, "<leader>aa", "<C-a>", { desc = "光标数字数字相加" })

-- 查找替换
map({ "n", "v" }, '<leader><leader>s', sr.search_selection_content, { desc = "搜索当前选中内容" })
map({ "n", "v" }, '<leader><leader>r', sr.replace_selection_content, { desc = "替换当前选中内容" })

-- Tab 缩进
map({ "n", "v" }, '<Tab>', '>gv', { noremap = true, silent = true })

-- Shift+Tab 反缩进
map({ "n", "v" }, '<S-Tab>', '<gv', { noremap = true, silent = true })
-- ======================================================================== 自定义快捷键开始

-- ======================================================================== hop 插件快捷键开始
---按需加载 hop 模块, 避免插件懒加载阶段在启动时直接 require 失败。
---@return table, table, table
local function load_hop_modules()
    local hop = require("hop")
    local directions = require("hop.hint").HintDirection
    local positions = require("hop.hint").HintPosition
    return hop, directions, positions
end

map({ "n", "v" }, "<leader><leader>w", function()
    local hop, directions = load_hop_modules()
    hop.hint_words({ direction = directions.AFTER_CURSOR })
end, { desc = "跳转到下一个单词的开头" })

map({ "n", "v" }, "<leader><leader>e", function()
    local hop, directions, positions = load_hop_modules()
    hop.hint_words({ direction = directions.AFTER_CURSOR, hint_position = positions.END })
end, { desc = "跳转到下一个单词的结尾" })

map({ "n", "v" }, "<leader><leader>b", function()
    local hop, directions = load_hop_modules()
    hop.hint_words({ direction = directions.BEFORE_CURSOR })
end, { desc = "跳转到上一个单词的开头" })

map({ "n", "v" }, "<leader><leader>v", function()
    local hop, directions, positions = load_hop_modules()
    hop.hint_words({ direction = directions.BEFORE_CURSOR, hint_position = positions.END })
end, { desc = "跳转到上一个单词的结尾" })

map({ "n", "v" }, "<leader><leader>l", function()
    local hop, directions = load_hop_modules()
    hop.hint_camel_case({ direction = directions.AFTER_CURSOR })
end, { desc = "跳转到下一个单词的开头（驼峰命名）" })

map({ "n", "v" }, "<leader><leader>h", function()
    local hop, directions = load_hop_modules()
    hop.hint_camel_case({ direction = directions.BEFORE_CURSOR })
end, { desc = "跳转到上一个单词的开头（驼峰命名）" })

map({ "n", "v" }, "<leader><leader>a", function()
    local hop = load_hop_modules()
    hop.hint_anywhere({})
end, { desc = "跳转到任意字符" })

map({ "n", "v" }, "<leader><leader>j", function()
    local hop, directions = load_hop_modules()
    hop.hint_lines({ direction = directions.AFTER_CURSOR })
end, { desc = "向下跳转(行)" })

map({ "n", "v" }, "<leader><leader>k", function()
    local hop, directions = load_hop_modules()
    hop.hint_lines({ direction = directions.BEFORE_CURSOR })
end, { desc = "向上跳转(行)" })
-- ======================================================================== hop 插件快捷键结束
