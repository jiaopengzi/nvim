-- FilePath     : \nvim\lua\plugins\yazi.nvim.lua
-- Description  : 文件管理

return {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    -- 👇 if you use `open_for_directories=true`, this is recommended
    init = function()
        -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
        -- vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
    end,

    dependencies = {
        -- check the installation instructions at
        -- https://github.com/folke/snacks.nvim
        "folke/snacks.nvim",
        "nvim-lua/plenary.nvim",
    },

    keys = {
        -- 👇 in this section, choose your own keymappings!
        {
            "<leader><leader>",
            mode = { "n", "v" },
            "<cmd>Yazi<cr>",
            desc = "使用 Yazi 打开文件管理器",
        },
        {
            -- Open in the current working directory
            "<leader>cw",
            "<cmd>Yazi cwd<cr>",
            desc = "使用 Yazi 打开当前工作目录",
        },
        {
            "<c-up>",
            "<cmd>Yazi toggle<cr>",
            desc = "切换到上一次的 Yazi 会话",
        },
    },
    opts = {
        -- if you want to open yazi instead of netrw, see below for more info
        open_for_directories = true,
        keymaps = {
            show_help = "<f1>",
        },
    },
}
