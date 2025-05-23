-- FilePath    : nvim\lua\plugins\neovim\fzf-lua.lua
-- Description : 查询 搜索

return {
    "ibhagwan/fzf-lua",
    event = "VeryLazy",
    cmd = { "FzfLua" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
}
