local ok, _ = pcall(require, "telescope")
if not ok then return end

local builtin = require("telescope.builtin")

local function zig_std_dir()
  local out = vim.fn.system("zig env")
  -- zon format: .std_dir = "..."
  local dir = out:match('%.std_dir%s*=%s*"([^"]+)"')
  -- JSON format: "std_dir": "..."
  if not dir then
    dir = out:match('"std_dir"%s*:%s*"([^"]+)"')
  end
  return dir
end

local function search_zig_std()
  local dir = zig_std_dir()
  if not dir then
    vim.notify("Could not determine Zig std dir (is zig installed?)", vim.log.levels.WARN)
    return
  end
  builtin.live_grep({
    prompt_title = "Zig Stdlib",
    cwd = dir,
    default_text = "pub fn ",
  })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "zig",
  callback = function(ev)
    vim.keymap.set("n", "<leader>fs", search_zig_std, { buffer = ev.buf, desc = "Search Zig stdlib" })
  end,
})
