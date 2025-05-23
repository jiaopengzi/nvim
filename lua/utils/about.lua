-- FilePath    : nvim\lua\utils\about.lua
-- Author      : jiaopengzi
-- Blog        : https://jiaopengzi.com
-- Copyright   : Copyright (c) 2025 by jiaopengzi, All Rights Reserved.
-- Description : 关于信息

local M = {}
local v = vim.version()
local version = string.format("%d.%d.%d", v.major, v.minor, v.patch)

M.version = version
M.author = "jiaopengzi"

return M
