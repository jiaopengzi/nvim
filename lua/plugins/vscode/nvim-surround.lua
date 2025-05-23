-- FilePath    : nvim\lua\plugins\vscode\nvim-surround.lua
-- Description  : 自动补全括号、引号等

return {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
        require("nvim-surround").setup({
            -- Configuration here, or leave empty to use defaults
        })
    end,
}
