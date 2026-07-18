-- FilePath    : nvim\lua\plugins\neovim\dashboard-nvim.lua
-- Description : 面板

return {

    "nvimdev/dashboard-nvim",
    lazy = false,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },

    -- https://patorjk.com/software/taag/#p=display&f=ANSI%20Shadow&t=jnvim

    opts = function()
        local logo = [[
███╗   ██╗ ██╗   ██╗ ██╗ ███╗   ███╗
████╗  ██║ ██║   ██║ ██║ ████╗ ████║
██╔██╗ ██║ ██║   ██║ ██║ ██╔████╔██║
██║╚██╗██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║
██║ ╚████║  ╚████╔╝  ██║ ██║ ╚═╝ ██║
╚═╝  ╚═══╝   ╚═══╝   ╚═╝ ╚═╝     ╚═╝
]]
        local version = string.format("%s", require("utils.about").version)
        local info = string.rep("\n", 8) .. logo .. "\n" .. "v" .. version .. "\n"


        local opts = {
            theme = "doom",
            hide = {
                -- this is taken care of by lualine
                -- enabling this messes up the actual laststatus setting after loading a file
                statusline = false,
            },

            config = {
                header = vim.split(info, "\n"),

                center = {
                    { icon = ' ', key = 'f', desc = '  Find File', action = ':FzfLua files', },
                    { icon = ' ', key = 'n', desc = '  New File', action = ':ene | startinsert', },
                    { icon = ' ', key = 'g', desc = '  Find Text', action = ':FzfLua live_grep', },
                    { icon = ' ', key = 'r', desc = '  Recent Files', action = ':FzfLua oldfiles', },
                    { icon = ' ', key = 'c', desc = '  Config', action = ':lua require("yazi").yazi({}, vim.fn.stdpath("config"))', },
                    { icon = ' ', key = 'p', desc = '  Plugins', action = ':PackStatus', },
                    { icon = ' ', key = 'q', desc = '  Quit', action = ':qa', },
                },

                footer = function()
                    local stats = require("config.pack").stats()
                    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                    return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
                end,
            },
        }

        for _, button in ipairs(opts.config.center) do
            button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
            button.key_format = "  %s"
        end

        return opts
    end,

}
