-- FilePath    : nvim\lua\plugins\neovim\grug-far.lua
-- Description : 全局查找替换

return {

    "MagicDuck/grug-far.nvim",
    event = "VeryLazy",
    opts = { headerMaxWidth = 80 },
    cmd = "GrugFar",
    keys = {
        {
            "<leader>sr",
            function()
                local grug = require("grug-far")
                local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
                grug.open({
                    transient = true,
                    prefills = {
                        filesFilter = ext and ext ~= "" and "*." .. ext or {},
                    },
                })
            end,
            mode = { "n", "v" },
            desc = "Search and Replace",
        },
    },

}
