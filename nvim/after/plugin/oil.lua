local ok, oil = pcall(require, "oil")
if not ok then return end

oil.setup({
  view_options = {
    show_hidden = true,
    is_always_hidden = function(name, bufnr) return name:match(".*_templ.*$") ~= nil end,
  },
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { noremap = true, desc = "Open oil" })
