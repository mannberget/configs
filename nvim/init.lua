local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local opt = vim.opt

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.keymap.set(mode, lhs, rhs, options) -- Updated to native vim.keymap.set but kept your logic
end

--- Lazy.nvim ---
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "nvim-treesitter/nvim-treesitter",
    branch = 'master',
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")
      configs.setup({
        -- Removed: c, lua, vim, vimdoc, query (Neovim 0.11 provides these)
        ensure_installed = { "markdown", "markdown_inline", "go", "javascript", "python", "html", "css", "json", "typescript", "bash", "yaml", "toml", "dockerfile", },
        highlight = {
          enable = true,
          disable = function(lang, buf)
            local max_filesize = 100 * 1024
            local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then return true end
          end,
        },
        indent = { enable = true },
        sync_install = false,
        auto_install = true, 
      })
    end,
  },
  { "neovim/nvim-lspconfig" },
  { "nvim-lua/plenary.nvim" },
  { "nvim-telescope/telescope.nvim"},
  { "stevearc/oil.nvim" },
  { "folke/ts-comments.nvim" },
  { "nvimtools/none-ls.nvim" },
  { "github/copilot.vim" },
  { "saghen/blink.cmp"},
}, {
  defaults = { lazy = false },
  install = { missing = true },
})

-- Load custom plugin
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
map("n", "-", "<CMD>Oil<CR>", { desc = "Open oil" })
map('v', '<leader>y', '"+y')
map('n', '<leader>y', '"+y')
map('v', '<leader>p', '"_dP')
map('n', '<leader>cc', 'gcc', { noremap = false })
map('v', '<leader>c', 'gc', { noremap = false })
map("n", "<leader>ff", ":lua require'telescope.builtin'.find_files()<CR>", { silent = true })
map("n", "<leader>fb", ":lua require'telescope.builtin'.buffers()<CR>", { silent = true })
map("n", "<leader>fg", ":lua require'telescope.builtin'.live_grep()<CR>", { silent = true })
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

-- Telescope
require('telescope').setup{
  defaults = {
    file_ignore_patterns = { "node_modules/.*", "local_packages/.*", "%.env", "yarn.lock", "package-lock.json", "lazy-lock.json", "init.sql", "target/.*", ".git/.*" },
    mappings = {
      i = {
        ["<esc>"] = require('telescope.actions').close,
        ["<C-j>"] = require('telescope.actions').move_selection_next,
        ["<C-k>"] = require('telescope.actions').move_selection_previous,
        ["<C-s>"] = require('telescope.actions').toggle_selection,
        ["<C-u>"] = require('telescope.actions').preview_scrolling_up,
        ["<C-d>"] = require('telescope.actions').preview_scrolling_down,
      }
    }
  },
}

-- Set htmldjango filetype for .html files
vim.cmd [[ autocmd BufRead,BufNewFile *.html set filetype=htmldjango ]]

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function() vim.opt_local.wrap = true end,
})

require('oil').setup({
  view_options = {
    show_hidden = true,
    is_always_hidden = function(name, bufnr) return name:match(".*_templ.*$") ~= nil end
  }
})

-- Your original LspAttach logic
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    if client == nil then return end

    if client.name == 'ruff' then client.server_capabilities.hoverProvider = false end
    if client.name == 'pyright' then client.server_capabilities.publishDiagnostics = false end

    vim.keymap.set('n', 'gE', vim.diagnostic.goto_prev, bufopts)
    vim.keymap.set('n', 'ge', vim.diagnostic.goto_next, bufopts)
    vim.keymap.set('n', '<leader>ge', function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, bufopts)

    if client.server_capabilities.completionProvider then vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc" end
    if client.server_capabilities.definitionProvider then vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc" end
    if client.supports_method('textDocument/rename') then vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts) end
    if client.supports_method('textDocument/definition') then vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts) end
    if client.supports_method('textDocument/references') then vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts) end
    if client.supports_method('textDocument/formatting') then vim.keymap.set('n', '<leader>fo', vim.lsp.buf.format, bufopts) end
    if client.supports_method('textDocument/codeAction') then vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts) end
    if client.supports_method('textDocument/implementation') then vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts) end
  end,
})


-- Modern Language Server Integrations (Neovim 0.11 style)
vim.lsp.config('gopls', {})
vim.lsp.config('ruff', {})
vim.lsp.config('ccls', {
  init_options = {
    compilationDatabaseDirectory = "build",
    index = { threads = 0 },
  }
})

vim.lsp.config('pyright', {
  settings = {
    pyright = {
      disableOrganizeImports = true,
      useLibraryCodeForTypes = false,
    },
    python = {
      analysis = {
        ignore = { '*' },
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "off",
        autoSearchPaths = false,
        useLibraryCodeForTypes = false,
      },
    },
  },
})

-- Enable the language servers
vim.lsp.enable('gopls')
vim.lsp.enable('ruff')
vim.lsp.enable('pyright')
vim.lsp.enable('ccls')

-- Setup null-ls
local null_ls = require("null-ls")

null_ls.setup({
    sources = {
        null_ls.builtins.formatting.djlint,
        null_ls.builtins.diagnostics.djlint,
    },
})

require('ts-comments').setup{}
