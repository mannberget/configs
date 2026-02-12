local ok, telescope = pcall(require, "telescope")
if not ok then return end

local actions = require("telescope.actions")

telescope.setup({
  defaults = {
    file_ignore_patterns = { "node_modules/.*", "local_packages/.*", "%.env", "yarn.lock", "package-lock.json", "lazy-lock.json", "init.sql", "target/.*", ".git/.*" },
    mappings = {
      i = {
        ["<esc>"] = actions.close,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-s>"] = actions.toggle_selection,
        ["<C-u>"] = actions.preview_scrolling_up,
        ["<C-d>"] = actions.preview_scrolling_down,
      },
    },
  },
})

vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, { noremap = true, silent = true })
