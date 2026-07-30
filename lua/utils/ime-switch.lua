-- FilePath    : nvim\lua\utils\ime-switch.lua
-- Author      : jiaopengzi
-- Blog        : https://jiaopengzi.com
-- Copyright   : Copyright (c) 2025 by jiaopengzi, All Rights Reserved.
-- Description : 输入法切换模块(Input method editor switch)
--               直接调用 Windows IME 系统 API 切换中英文, 不依赖任何输入法快捷键

local M = {}

local ffi = require("ffi") -- 使用 LuaJIT 的 FFI 库调用 Windows API

-- 声明所需的 Windows IME 相关 API
ffi.cdef [[
    void*   GetForegroundWindow(void);
    void*   ImmGetDefaultIMEWnd(void* hWnd);
    intptr_t SendMessageW(void* hWnd, unsigned int Msg, uintptr_t wParam, intptr_t lParam);
    void*   ImmGetContext(void* hWnd);
    int     ImmReleaseContext(void* hWnd, void* hIMC);
    int     ImmSetOpenStatus(void* hIMC, int fOpen);
    int     ImmGetOpenStatus(void* hIMC);
]]

-- 加载所需 DLL(user32/imm32), 加载失败时回退到默认 C 命名空间
local ok_user32, user32 = pcall(ffi.load, "user32")
if not ok_user32 then
    user32 = ffi.C
end
local ok_imm32, imm32 = pcall(ffi.load, "imm32")
if not ok_imm32 then
    imm32 = ffi.C
end

-- WM_IME_CONTROL 消息及其子命令, 用于通过默认 IME 窗口读写开关状态
local WM_IME_CONTROL    = 0x0283
local IMC_GETOPENSTATUS = 0x0005
local IMC_SETOPENSTATUS = 0x0006

local NULL              = ffi.new("void*", nil)

-- 通过 ImmSetOpenStatus 设置前台窗口的输入法开关状态
-- @param open boolean true 为中文(打开), false 为英文(关闭)
-- @return boolean 是否设置成功
local function set_open_status_by_context(hwnd, open)
    local himc = imm32.ImmGetContext(hwnd)
    if himc == NULL then
        return false
    end

    local ret = imm32.ImmSetOpenStatus(himc, open and 1 or 0)
    imm32.ImmReleaseContext(hwnd, himc)
    return ret ~= 0
end

-- 通过默认 IME 窗口发送 WM_IME_CONTROL 消息设置输入法开关状态
-- @param open boolean true 为中文(打开), false 为英文(关闭)
-- @return boolean 是否设置成功
local function set_open_status_by_ime_window(hwnd, open)
    local ime_wnd = imm32.ImmGetDefaultIMEWnd(hwnd)
    if ime_wnd == NULL then
        return false
    end

    user32.SendMessageW(ime_wnd, WM_IME_CONTROL, IMC_SETOPENSTATUS, open and 1 or 0)
    return true
end

-- 设置输入法开关状态, 优先使用输入上下文, 失败时回退到默认 IME 窗口消息
-- @param open boolean true 为中文, false 为英文
local function set_open_status(open)
    local hwnd = user32.GetForegroundWindow()
    if hwnd == NULL then
        return
    end

    if set_open_status_by_context(hwnd, open) then
        return
    end

    set_open_status_by_ime_window(hwnd, open)
end

-- 切换到中文输入法
function M.switch_to_chinese()
    set_open_status(true)
end

-- 切换到英文输入法
function M.switch_to_english()
    set_open_status(false)
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
