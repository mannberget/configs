local ok, ts = pcall(require, "nvim-treesitter")
if not ok then return end

ts.setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
})

local ensure = {
  "bash", "css", "dockerfile", "go", "html", "javascript", "json",
  "lua", "markdown", "markdown_inline", "python", "query", "toml",
  "typescript", "vim", "vimdoc", "yaml",
}

pcall(ts.install, ensure)

vim.treesitter.language.register("html", "htmldjango")

local ft = {
  "bash", "css", "dockerfile", "go", "html", "htmldjango", "javascript",
  "json", "lua", "markdown", "python", "sh", "toml", "typescript", "vim",
  "help", "yaml",
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = ft,
  callback = function(args)
    local max_filesize = 100 * 1024
    local s, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
    if s and stats and stats.size > max_filesize then return end
    pcall(vim.treesitter.start, args.buf)
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
