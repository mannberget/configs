local ok, configs = pcall(require, "nvim-treesitter.configs")
if not ok then return end

configs.setup({
  ensure_installed = { "markdown", "markdown_inline", "go", "javascript", "python", "html", "css", "json", "typescript", "bash", "yaml", "toml", "dockerfile" },
  highlight = {
    enable = true,
    disable = function(lang, buf)
      local max_filesize = 100 * 1024
      local s, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
      if s and stats and stats.size > max_filesize then return true end
    end,
  },
  indent = { enable = true },
  sync_install = false,
  auto_install = true,
})
