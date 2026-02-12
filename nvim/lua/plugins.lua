local M = {}

local plugin_dir = vim.fn.stdpath("data") .. "/plugins"

local function plugin_name(spec)
  return spec[1]:match("[^/]+$")
end

local function plugin_path(spec)
  return plugin_dir .. "/" .. plugin_name(spec)
end

local function source_plugin(path)
  for _, dir in ipairs({ "plugin", "after/plugin" }) do
    local full = path .. "/" .. dir
    if vim.fn.isdirectory(full) == 1 then
      for _, f in ipairs(vim.fn.glob(full .. "/**/*.lua", false, true)) do
        vim.cmd("source " .. f)
      end
      for _, f in ipairs(vim.fn.glob(full .. "/**/*.vim", false, true)) do
        vim.cmd("source " .. f)
      end
    end
  end
end

local function run_build(spec, path)
  if not spec.build then return end
  if spec.build:sub(1, 1) == ":" then
    vim.cmd(spec.build:sub(2))
  else
    vim.fn.system({ "sh", "-c", spec.build, }, path)
  end
end

function M.load()
  local plugins = require("plugin-list")
  for _, spec in ipairs(plugins) do
    local path = plugin_path(spec)
    if vim.fn.isdirectory(path) == 1 then
      vim.opt.rtp:prepend(path)
      local after = path .. "/after"
      if vim.fn.isdirectory(after) == 1 then
        vim.opt.rtp:append(after)
      end
    end
  end

  vim.api.nvim_create_user_command("PInstall", function() M.install() end, {})
  vim.api.nvim_create_user_command("PUpdate", function() M.update() end, {})
  vim.api.nvim_create_user_command("PClean", function() M.clean() end, {})
end

function M.install()
  vim.fn.mkdir(plugin_dir, "p")
  local plugins = require("plugin-list")
  for _, spec in ipairs(plugins) do
    local path = plugin_path(spec)
    if vim.fn.isdirectory(path) == 0 then
      local url = "https://github.com/" .. spec[1] .. ".git"
      print("Installing " .. spec[1] .. "...")
      local cmd = { "git", "clone", "--depth", "1" }
      if spec.branch then
        table.insert(cmd, "--branch")
        table.insert(cmd, spec.branch)
      end
      table.insert(cmd, url)
      table.insert(cmd, path)
      vim.fn.system(cmd)
      if vim.v.shell_error ~= 0 then
        print("Failed to install " .. spec[1])
      else
        vim.opt.rtp:prepend(path)
        local after = path .. "/after"
        if vim.fn.isdirectory(after) == 1 then
          vim.opt.rtp:append(after)
        end
        source_plugin(path)
        run_build(spec, path)
        print("Installed " .. spec[1])
      end
    end
  end
end

function M.update()
  local plugins = require("plugin-list")
  for _, spec in ipairs(plugins) do
    local path = plugin_path(spec)
    if vim.fn.isdirectory(path) == 1 then
      print("Updating " .. spec[1] .. "...")
      vim.fn.system({ "git", "-C", path, "pull", "--ff-only" })
      if vim.v.shell_error ~= 0 then
        print("Failed to update " .. spec[1])
      else
        source_plugin(path)
        run_build(spec, path)
        print("Updated " .. spec[1])
      end
    end
  end
end

function M.clean()
  if vim.fn.isdirectory(plugin_dir) == 0 then return end
  local plugins = require("plugin-list")
  local wanted = {}
  for _, spec in ipairs(plugins) do
    wanted[plugin_name(spec)] = true
  end
  local installed = vim.fn.readdir(plugin_dir)
  local to_remove = {}
  for _, name in ipairs(installed) do
    if not wanted[name] and vim.fn.isdirectory(plugin_dir .. "/" .. name) == 1 then
      table.insert(to_remove, name)
    end
  end
  if #to_remove == 0 then
    print("Nothing to clean")
    return
  end
  for _, name in ipairs(to_remove) do
    print("Removing " .. name .. "...")
    vim.fn.delete(plugin_dir .. "/" .. name, "rf")
  end
  print("Removed " .. #to_remove .. " plugin(s). Restart nvim to fully unload.")
end

return M
