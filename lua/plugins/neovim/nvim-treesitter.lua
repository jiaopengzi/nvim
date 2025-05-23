-- FilePath    : nvim\lua\plugins\neovim\nvim-treesitter.lua
-- Description : 语法高亮

return {
    "nvim-treesitter/nvim-treesitter",
    enabled = false,
    event = "VeryLazy",
    build = ":TSUpdate",
    opts = {
        ensure_installed = { "lua", "python", "go", "vue", "typescript", "javascript", "scss", "css", "yaml", "markdown", "sql" }, -- 需要安装的语言
        highlight = {
            enable = true,                                                                                                         -- 启用语法高亮
            additional_vim_regex_highlighting = false,                                                                             -- 是否启用额外的正则表达式高亮
        },
        indent = {
            enable = true, -- 启用缩进
        },
    },
    config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts) -- 设置配置
    end,
}
