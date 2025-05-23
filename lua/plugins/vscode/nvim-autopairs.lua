-- FilePath    : nvim\lua\plugins\vscode\nvim-autopairs.lua
-- Description  : 自动补全括号、引号等

return {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true,
    vscode = false,
    opts = {},
}
