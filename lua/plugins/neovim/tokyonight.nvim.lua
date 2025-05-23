-- FilePath : \nvim\lua\plugins\tokyonight.nvim.lua

return {
    "folke/tokyonight.nvim",
    lazy = false, -- 主题不需要懒加载
    opts = {
        styles = {
            -- 取消斜体
            comments = { italic = false },
            keywords = { italic = false },
            functions = { italic = false },
            variables = { italic = false },
        },
    },

    config = function(_, opts)
        -- 设置主题
        require("tokyonight").setup(opts)
        vim.cmd([[colorscheme tokyonight-night]])
    end,
}
