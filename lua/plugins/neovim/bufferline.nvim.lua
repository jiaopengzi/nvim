-- FilePath    : nvim\lua\plugins\neovim\bufferline.nvim.lua
-- Description : bufferline 即 标签

return {
    "akinsho/bufferline.nvim",
    lazy = false, -- 让插件在启动时加载
    dependencies = { 'nvim-tree/nvim-web-devicons' },

    keys = {
        { "<leader>bh", ":BufferLineCyclePrev<CR>", silent = true, desc = "切换到上一个缓冲区" },
        { "<leader>bl", ":BufferLineCycleNext<CR>", silent = true, desc = "切换到下一个缓冲区" },
        { "<leader>bd", ":BufferLineClose 0<CR><ESC>", silent = true, desc = "关闭当前缓冲区" },
        { "<leader>bo", ":BufferLineCloseOthers<CR>", silent = true, desc = "关闭其他缓冲区" },
        { "<leader>bp", ":BufferLinePick<CR>", silent = true, desc = "选择缓冲区" },
        { "<leader>bc", ":BufferLinePickClose<CR>", silent = true, desc = "选择并关闭缓冲区" },
        { "<leader>be", ":BufferLinePickClose<CR>", silent = true, desc = "选择并关闭缓冲区" },
        { "<leader>bH", "<Cmd>IceRepeat BufferLineMovePrev<CR>", silent = true, desc = "向左移动" },
        { "<leader>bL", "<Cmd>IceRepeat BufferLineMoveNext<CR>", silent = true, desc = "向右移动" },
    },

    opts = {},
}
