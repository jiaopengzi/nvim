-- FilePath    : nvim\lua\utils\virtual-keyboard.lua
-- Author      : jiaopengzi
-- Blog        : https://jiaopengzi.com
-- Copyright   : Copyright (c) 2025 by jiaopengzi, All Rights Reserved.
-- Description : 虚拟键盘模, 用于模拟各种键盘输入

-- **注意在 windows 终端中使用确保使用的是管理员权限运行，否则无法模拟按键**

local M = {}

local ffi = require("ffi") -- 使用 LuaJIT 的 FFI 库调用 C 函数

-- 定义 Windows API 函数
ffi.cdef [[
    void keybd_event(unsigned char bVk, unsigned char bScan, unsigned long dwFlags, unsigned long dwExtraInfo);
]]

M.Key = {
    VK_Backspace    = 0x08, -- Backspace
    VK_Tab          = 0x09, -- Tab
    VK_Enter        = 0x0D, -- Enter/Return
    VK_Shift        = 0x10, -- Shift (通用，不区分左右)
    VK_Control      = 0x11, -- Ctrl (通用，不区分左右)
    VK_ALT          = 0x12, -- Alt (通用，不区分左右)
    VK_CapsLock     = 0x14, -- CapsLock
    VK_Esc          = 0x1B, -- Escape
    VK_Space        = 0x20, -- Space
    VK_PageUp       = 0x21, -- Page Up
    VK_PageDown     = 0x22, -- Page Down
    VK_End          = 0x23, -- End
    VK_Home         = 0x24, -- Home
    VK_Left         = 0x25, -- Left Arrow
    VK_Up           = 0x26, -- Up Arrow
    VK_Right        = 0x27, -- Right Arrow
    VK_Down         = 0x28, -- Down Arrow
    VK_PrintScreen  = 0x2C, -- Print Screen
    VK_Insert       = 0x2D, -- Insert
    VK_Delete       = 0x2E, -- Delete

    -- 数字键 (顶排)
    -- 0x30 - 0x39
    VK_0            = 0x30, -- 0
    VK_1            = 0x31, -- 1
    VK_2            = 0x32, -- 2
    VK_3            = 0x33, -- 3
    VK_4            = 0x34, -- 4
    VK_5            = 0x35, -- 5
    VK_6            = 0x36, -- 6
    VK_7            = 0x37, -- 7
    VK_8            = 0x38, -- 8
    VK_9            = 0x39, -- 9

    -- 字母键 A - Z
    VK_A            = 0x41,
    VK_B            = 0x42,
    VK_C            = 0x43,
    VK_D            = 0x44,
    VK_E            = 0x45,
    VK_F            = 0x46,
    VK_G            = 0x47,
    VK_H            = 0x48,
    VK_I            = 0x49,
    VK_J            = 0x4A,
    VK_K            = 0x4B,
    VK_L            = 0x4C,
    VK_M            = 0x4D,
    VK_N            = 0x4E,
    VK_O            = 0x4F,
    VK_P            = 0x50,
    VK_Q            = 0x51,
    VK_R            = 0x52,
    VK_S            = 0x53,
    VK_T            = 0x54,
    VK_U            = 0x55,
    VK_V            = 0x56,
    VK_W            = 0x57,
    VK_X            = 0x58,
    VK_Y            = 0x59,
    VK_Z            = 0x5A,

    -- 系统键 & 功能键
    VK_LWin         = 0x5B, -- Left Windows
    VK_RWin         = 0x5C, -- Right Windows
    VK_Apps         = 0x5D, -- Menu/Apps Key

    -- 功能键 F1 - F12
    VK_F1           = 0x70,
    VK_F2           = 0x71,
    VK_F3           = 0x72,
    VK_F4           = 0x73,
    VK_F5           = 0x74,
    VK_F6           = 0x75,
    VK_F7           = 0x76,
    VK_F8           = 0x77,
    VK_F9           = 0x78,
    VK_F10          = 0x79,
    VK_F11          = 0x7A,
    VK_F12          = 0x7B,

    -- 指示灯
    -- 0x90 - 0x91
    VK_NumLock      = 0x90,
    VK_ScrollLock   = 0x91,

    -- 左右分离的修饰键 (可选, 某些场景需区分左右)
    VK_LShift       = 0xA0, -- Left Shift
    VK_RShift       = 0xA1, -- Right Shift
    VK_LControl     = 0xA2, -- Left Ctrl
    VK_RControl     = 0xA3, -- Right Ctrl
    VK_LAlt         = 0xA4, -- Left Alt
    VK_RAlt         = 0xA5, -- Right Alt

    -- 符号键 (OEM 键区)
    -- 0xBA - 0xDE
    VK_OEM_1        = 0xBA, -- ;:
    VK_OEM_PLUS     = 0xBB, -- =+
    VK_OEM_COMMA    = 0xBC, -- ,<
    VK_OEM_MINUS    = 0xBD, -- -_
    VK_OEM_PERIOD   = 0xBE, -- .>
    VK_OEM_2        = 0xBF, -- /?
    VK_OEM_3        = 0xC0, -- `~
    VK_OEM_4        = 0xDB, -- [{
    VK_OEM_5        = 0xDC, -- \|
    VK_OEM_6        = 0xDD, -- ]}
    VK_OEM_7        = 0xDE, -- '"

    -- 键盘事件标志
    KEYEVENTF_KEYUP = 0x0002, -- 按键抬起
}


-- 模拟 ctrl 组合键
-- @param vk_key 需要的键位
function M.press_ctrl_key(vk_key)
    -- 按下 Ctrl 和 目标键
    ffi.C.keybd_event(M.Key.VK_Control, 0, 0, 0)
    ffi.C.keybd_event(vk_key, 0, 0, 0)

    -- 松开目标键和 Ctrl
    ffi.C.keybd_event(vk_key, 0, M.Key.KEYEVENTF_KEYUP, 0)
    ffi.C.keybd_event(M.Key.VK_Control, 0, M.Key.KEYEVENTF_KEYUP, 0)
end

-- 模拟按键 ctrl shift 组合键
-- @param vk_key 需要的键位
function M.press_ctrl_shift_key(vk_key)
    -- 按下 ctrl shift 和 目标键
    ffi.C.keybd_event(M.Key.VK_Control, 0, 0, 0)
    ffi.C.keybd_event(M.Key.VK_Shift, 0, 0, 0)
    ffi.C.keybd_event(vk_key, 0, 0, 0)

    -- 松开目标键和 Ctrl
    ffi.C.keybd_event(vk_key, 0, M.Key.KEYEVENTF_KEYUP, 0)
    ffi.C.keybd_event(M.Key.VK_Shift, 0, M.Key.KEYEVENTF_KEYUP, 0)
    ffi.C.keybd_event(M.Key.VK_Control, 0, M.Key.KEYEVENTF_KEYUP, 0)
end

-- 模拟按键
-- @param vk_key 需要的键位
function M.press_key(vk_key)
    -- 按下目标键
    ffi.C.keybd_event(vk_key, 0, 0, 0)

    -- 松开目标键
    ffi.C.keybd_event(vk_key, 0, M.Key.KEYEVENTF_KEYUP, 0)
end

return M
