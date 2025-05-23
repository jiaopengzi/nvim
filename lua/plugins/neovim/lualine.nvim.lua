-- FilePath    : nvim\lua\plugins\neovim\lualine.nvim.lua
-- Description : 底部状态栏

return {
    "nvim-lualine/lualine.nvim",
    lazy = false, -- 让插件在启动时加载
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
        options = {
            icons_enabled = true,
            theme = "auto",
            -- component_separators = { left = "", right = "" },
            -- section_separators = { left = "", right = "" },
            disabled_filetypes = { statusline = { "dashboard", "yazi" } },
            always_divide_middle = true,
        },
    },
}
