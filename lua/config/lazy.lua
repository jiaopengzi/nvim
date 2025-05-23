-- FilePath    : nvim\lua\config\lazy.lua
-- 参考：https://lazy.folke.io/installation
-- 使用命令 :Lazy 查看插件管理器的状态(注意是大写的 L )
-- 使用命令 :checkhealth lazy 查看 lazy.nvim 的健康状态

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "       -- 设置主键映射为空格
vim.g.maplocalleader = "\\" -- 设置本地主键映射为反斜杠

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },

  defaults = {
    lazy = false,    -- 是否懒加载插件
    version = false, -- 使用最新 commit 版本 (version = "*", 使用最新稳定版)
  },

  checker = { enabled = true },
})
