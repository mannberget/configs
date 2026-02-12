local ok, cmp = pcall(require, "blink.cmp")
if not ok then return end

cmp.setup({
  keymap = { preset = "default" },
  appearance = {
    nerd_font_variant = "mono",
  },
  completion = {
    documentation = { auto_show = true },
    list = { selection = { preselect = false, auto_insert = true } },
  },
  signature = { enabled = true },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  fuzzy = { implementation = "lua" },
})
