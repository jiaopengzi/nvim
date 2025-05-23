-- FilePath    : nvim\lua\config\options.lua
-- Description : 编辑器选项
-- 参考: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local g = vim.g
local opt = vim.opt

g.markdown_recommended_style = 0 -- 修复 Markdown 缩进设置

g.deprecation_warnings = true    -- 显示弃用警告

-- 在 lualine 中显示 Trouble 提供的当前文档符号位置
-- 可以通过设置 `vim.b.trouble_lualine = false` 来为某个缓冲区禁用此功能
g.trouble_lualine = true

opt.autowrite = true -- 启用自动保存

-- 如果不是在 SSH 环境中才设置剪贴板，以确保 OSC 52 集成自动工作
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- 同步系统剪贴板
opt.completeopt = "menu,menuone,noselect" -- 自动补全选项
opt.conceallevel = 2 -- 隐藏 * 的加粗和斜体标记，但不隐藏带替换的标记
opt.confirm = true -- 在退出修改过的缓冲区前确认保存更改
opt.cursorline = true -- 高亮当前行
opt.expandtab = true -- 使用空格代替 Tab
opt.fillchars = {
    foldopen = "", -- 折叠打开符号
    foldclose = "", -- 折叠关闭符号
    fold = " ", -- 折叠填充字符
    foldsep = " ", -- 折叠分隔符
    diff = "╱", -- 差异填充字符
    eob = " ", -- 文件末尾填充字符
}
opt.foldlevel = 99 -- 默认展开折叠层级
-- opt.formatexpr = "v:lua.require'lazyvim.util'.format.formatexpr()" -- 格式化表达式
opt.formatoptions = "jcroqlnt" -- 格式化选项
opt.grepformat = "%f:%l:%c:%m" -- grep 输出格式
opt.grepprg = "rg --vimgrep" -- 使用 ripgrep 作为 grep 程序
opt.ignorecase = true -- 忽略大小写
opt.inccommand = "nosplit" -- 增量替换预览
opt.jumpoptions = "view" -- 跳转选项
opt.laststatus = 3 -- 全局状态栏
opt.linebreak = true -- 在合适的位置换行
opt.list = true -- 显示一些不可见字符（如制表符等）
opt.mouse = "a" -- 启用鼠标模式
opt.number = true -- 显示行号
opt.pumblend = 10 -- 弹出菜单透明度
opt.pumheight = 10 -- 弹出菜单最大条目数
opt.relativenumber = true -- 显示相对行号
opt.ruler = false -- 禁用默认标尺
opt.scrolloff = 4 -- 上下文行数
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" } -- 会话选项
opt.shiftround = true -- 缩进时对齐到最近的缩进级别
opt.shiftwidth = 2 -- 缩进宽度
opt.shortmess:append({ W = true, I = true, c = true, C = true }) -- 缩短消息选项
-- opt.showmode = g.vscode and true or false -- 显示模式 VSCode 中为 true，其他为 false
opt.showmode = g.vscode and true or false -- 显示模式（VSCode 中为 true，其他为 false）
opt.sidescrolloff = 8 -- 左右滚动的上下文列数
opt.signcolumn = "yes" -- 始终显示标志列
opt.smartcase = true -- 使用大写字母时不忽略大小写
opt.smartindent = true -- 自动插入缩进
opt.spelllang = { "en" } -- 拼写检查语言
opt.splitbelow = true -- 新窗口在当前窗口下方
opt.splitkeep = "screen" -- 保持屏幕布局
opt.splitright = true -- 新窗口在当前窗口右侧
-- opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]] -- 自定义状态列
opt.tabstop = 2 -- Tab 键宽度
opt.termguicolors = true -- 启用真彩色支持
opt.timeoutlen = g.vscode and 1000 or 300 -- 超时时间（VSCode 中为 1000，其他为 300）
opt.undofile = true -- 启用撤销文件
opt.undolevels = 10000 -- 撤销级别
opt.updatetime = 200 -- 保存交换文件并触发 CursorHold 的时间
opt.virtualedit = "block" -- 在可视块模式下允许光标移动到无文本处
opt.wildmode = "longest:full,full" -- 命令行补全模式
opt.winminwidth = 5 -- 最小窗口宽度
opt.wrap = false -- 禁用自动换行
opt.smoothscroll = true -- 启用平滑滚动
-- opt.foldexpr = "v:lua.require'lazyvim.util'.ui.foldexpr()" -- 折叠表达式
opt.foldmethod = "expr" -- 使用表达式折叠
opt.foldtext = "" -- 折叠文本

-- 要让yazi正常工作参考：https://github.com/mikavilpas/yazi.nvim/issues/882
vim.o.shell = "pwsh"
vim.o.shellcmdflag = "-nologo -noprofile -ExecutionPolicy RemoteSigned -command"
opt.shellxquote = ""
