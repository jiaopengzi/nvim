-- FilePath    : nvim\lua\utils\about.lua
-- Author      : jiaopengzi
-- Blog        : https://jiaopengzi.com
-- Copyright   : Copyright (c) 2025 by jiaopengzi, All Rights Reserved.
-- Description : 系统信息

local M = {}

function M.is_win()
    return vim.uv.os_uname().sysname:find("Windows") ~= nil
end

function M.is_mac()
    return vim.uv.os_uname().sysname:find("Darwin") ~= nil
end

function M.is_linux()
    return vim.uv.os_uname().sysname:find("Linux") ~= nil
end

return M
