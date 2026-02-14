local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local opt = vim.opt

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Plugin manager
require("plugins").load()

-- Statusline
pcall(require('statusline').setup, {})

--- OPTIONS ---
opt.compatible = false
opt.timeoutlen = 300
opt.guicursor = ""
opt.number = true
opt.visualbell = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.hlsearch = true
opt.incsearch = true
opt.scrolloff = 6
opt.laststatus = 2
opt.splitright = true
opt.smartindent = true
opt.termguicolors = true
opt.wrap = false
opt.encoding = "utf-8"
opt.cmdheight = 1
opt.undofile = true

g.mapleader = " "

vim.cmd [[
augroup CursorLine
    au!
    au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
augroup END
]]

-- Highlight settings
vim.cmd [[
  highlight Normal guibg=NONE
  highlight WinSeparator guibg=NONE guifg=gray
  highlight TelescopeResultsBorder guifg=white
  highlight TelescopePreviewBorder guifg=white
  highlight TelescopePromptBorder guifg=white
  highlight FloatBorder guifg=white
  highlight link markdownError NONE
]]

-- Restore cursor position when reopening files
vim.cmd [[
  autocmd BufReadPost * if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
]]

-- Disable netrw at the very start of your init.lua
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

--- KEYMAPS ---
vim.cmd("nnoremap <expr> <C-j> (winheight(0) / 5) . '<C-e>' . (winheight(0) / 5) . 'j'")
vim.cmd("nnoremap <expr> <C-k> (winheight(0) / 5) . '<C-y>' . (winheight(0) / 5) . 'k'")
map('n', '<leader>o', 'o<Esc>')
map('n', '<leader>O', 'O<Esc>')
map('v', '<leader>y', '"+y')
map('n', '<leader>y', '"+y')
map('v', '<leader>p', '"_dP')
map('n', '<leader>yp', ':let @+ = expand("%:.")<CR>:echo "File path copied to clipboard"<CR>', { silent = true })
map('n', '<leader>cc', 'gcc', { noremap = false })
map('v', '<leader>c', 'gc', { noremap = false })
map("n", "<leader>sv", "<C-w>v")
map("n", "<leader>sh", "<C-w>s")
map("n", "<leader>se", "<C-w>=")
map("n", "<leader>sx", ":close<CR>")
map("n", "<leader>gt", "<C-]>")
map("n", "<leader>j", "<cmd>cnext<CR>")
map("n", "<leader>k", "<cmd>cprev<CR>")
map("n", "<leader>l", "<cmd>cnfile<CR>")
map("n", "<leader>h", "<cmd>cpfile<CR>")
map("v", "<Tab>", ">gv")
map("v", "<S-Tab>", "<gv")
map("n", "H", "^")
map("n", "L", "$")
map('n', '<C-l>', '<cmd>vertical resize +5<CR>')
map('n', '<C-h>', '<cmd>vertical resize -5<CR>')

-- Set htmldjango filetype for .html files
vim.cmd [[ autocmd BufRead,BufNewFile *.html set filetype=htmldjango ]]

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function() vim.opt_local.wrap = true end,
})

-- Floating terminal
require("config.floaterminal")
