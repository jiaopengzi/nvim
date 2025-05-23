-- FilePath    : nvim\lua\plugins\init.lua
-- Author      : jiaopengzi
-- Blog        : https://jiaopengzi.com
-- Copyright   : Copyright (c) 2025 by jiaopengzi, All Rights Reserved.
-- Description : 插件入口

return {
    -- 在终端 neovim 中正常启用, 在 vscode 模式下 这些插件不启用
    { import = "plugins.neovim", enabled = not vim.g.vscode },
    { import = "plugins.vscode" },
}
