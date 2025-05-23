-- FilePath    : nvim\lua\utils\ime-switch.lua
-- Author      : jiaopengzi
-- Blog        : https://jiaopengzi.com
-- Copyright   : Copyright (c) 2025 by jiaopengzi, All Rights Reserved.
-- Description : 输入法切换模块(Input method editor switch)

-- **注意在 windows 终端中使用确保使用的是管理员权限运行，否则无法模拟按键**

local M = {}

local vk = require("utils.virtual-keyboard")

-- 切换到英文输入法辅助过渡
local function switch_to_english_auxiliary()
    vk.press_ctrl_key(vk.Key.VK_9) -- Ctrl + 9
end

-- 切换到中文输入法辅助过渡
local function switch_to_chinese_auxiliary()
    vk.press_ctrl_key(vk.Key.VK_8) -- Ctrl + 8
end

-- 切换到中文输入法
function M.switch_to_chinese()
    switch_to_english_auxiliary()
    switch_to_chinese_auxiliary()
end

-- 切换到英文输入法, 保证在中文输入法下按下 shift 键切换到英文输入法
function M.switch_to_english()
    M.switch_to_chinese()
    vk.press_key(vk.Key.VK_Shift) -- 按下 Shift 键切换输入法
end

-- 使用 Lua 模式匹配来检查是否是 CJK 基本区（U+4E00～U+9FFF）中的中文字符
function M.is_chinese_char(ch)
    -- UTF-8 下此区间的字节范围：0xE4B880 ~ 0xE9BFBF
    return ch:match("^[\228-\233][\128-\191][\128-\191]$") ~= nil
end

-- 判断是否是英文字符
function M.is_english_char(ch)
    return ch:match("[a-zA-Z]") ~= nil
end

-- 定义一个工具函数判断元素是否在表中
local function in_table(tbl, item)
    for _, value in ipairs(tbl) do
        if value == item then
            return true
        end
    end
    return false
end

-- 判断是否是中文标点符号
function M.is_chinese_symbol_char(ch)
    -- 定义中文常用的标点符号列表
    local chinese_symbols = {
        "，", "。", "？", "！", "：", "；", "“", "”", "‘", "’", "（", "）", "【", "】", "《", "》", "……", "——", "、", "·"
    }
    return in_table(chinese_symbols, ch)
end

function M.is_english_symbol_char(ch)
    -- 定义英文常用标点符号符号
    local english_symbols = {
        ",", ".", "?", "!", ":", ";", "\"", "'", "(", ")", "[", "]", "<", ">", "...", "-", "&", "/"
    }
    return in_table(english_symbols, ch)
end

-- 获取光标左侧/右侧的“字符”（非字节），并返回
local function get_char_left_of_cursor()
    local line = vim.api.nvim_get_current_line()
    local byte_col = vim.api.nvim_win_get_cursor(0)[2]
    local char_col = vim.str_utfindex(line, byte_col)

    if char_col == 0 then
        return nil
    end
    return vim.fn.strcharpart(line, char_col - 1, 1)
end

local function get_char_right_of_cursor()
    local line = vim.api.nvim_get_current_line()
    local byte_col = vim.api.nvim_win_get_cursor(0)[2]
    local total_bytes = #line
    if byte_col >= total_bytes then
        return nil
    end

    local char_col = vim.str_utfindex(line, byte_col)
    return vim.fn.strcharpart(line, char_col, 1)
end

-- 判断光标左/右侧是否是中文或英文状态
function M.check_char_at_cursor_left_is_chinese()
    local c = get_char_left_of_cursor()
    return (c ~= nil) and (M.is_chinese_char(c) or M.is_chinese_symbol_char(c))
end

function M.check_char_at_cursor_right_is_chinese()
    local c = get_char_right_of_cursor()
    return (c ~= nil) and (M.is_chinese_char(c) or M.is_chinese_symbol_char(c))
end

function M.check_char_at_cursor_left_is_english()
    local c = get_char_left_of_cursor()
    return (c ~= nil) and (M.is_english_char(c) or M.is_english_symbol_char(c))
end

function M.check_char_at_cursor_right_is_english()
    local c = get_char_right_of_cursor()
    return (c ~= nil) and (M.is_english_char(c) or M.is_english_symbol_char(c))
end

-- 在插入模式进入时切换输入法
function M.insert_enter()
    local left_is_en  = M.check_char_at_cursor_left_is_english()
    local right_is_en = M.check_char_at_cursor_right_is_english()
    local left_is_cn  = M.check_char_at_cursor_left_is_chinese()
    local right_is_cn = M.check_char_at_cursor_right_is_chinese()

    if left_is_en and right_is_en then
        -- 如果左右两侧都是英文字符，切换到英文输入法
        M.switch_to_english()
    elseif left_is_cn or right_is_cn then
        -- 如果左右两侧包含中文字符，切换到中文输入法
        M.switch_to_chinese()
    elseif left_is_en or right_is_en then
        -- 如果左右两侧包含英文字符，切换到英文输入法
        M.switch_to_english()
    else
        -- 默认切换到中文输入法
        M.switch_to_chinese()
    end
end

return M
