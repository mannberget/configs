vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    if client == nil then return end

    if client.name == "ruff" then client.server_capabilities.hoverProvider = false end
    if client.name == "pyright" then client.server_capabilities.publishDiagnostics = false end

    vim.keymap.set("n", "gE", vim.diagnostic.goto_prev, bufopts)
    vim.keymap.set("n", "ge", vim.diagnostic.goto_next, bufopts)
    vim.keymap.set("n", "<leader>ge", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, bufopts)

    if client.server_capabilities.completionProvider then vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc" end
    if client.server_capabilities.definitionProvider then vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc" end
    if client:supports_method("textDocument/rename") then vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts) end
    if client:supports_method("textDocument/definition") then vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts) end
    if client:supports_method("textDocument/references") then vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts) end
    if client:supports_method("textDocument/formatting") then vim.keymap.set("n", "<leader>fo", vim.lsp.buf.format, bufopts) end
    if client:supports_method("textDocument/codeAction") then vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts) end
    if client:supports_method("textDocument/implementation") then vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts) end
  end,
})

vim.lsp.config("zls", {})
vim.lsp.config("gopls", {})
vim.lsp.config("ruff", {})
vim.lsp.config("ccls", {
  init_options = {
    compilationDatabaseDirectory = "build",
    index = { threads = 0 },
  },
})

vim.lsp.config("pyright", {
  settings = {
    pyright = {
      disableOrganizeImports = true,
      useLibraryCodeForTypes = false,
    },
    python = {
      analysis = {
        ignore = { "*" },
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "off",
        autoSearchPaths = false,
        useLibraryCodeForTypes = false,
      },
    },
  },
})

vim.lsp.enable("zls")
vim.lsp.enable("gopls")
vim.lsp.enable("ruff")
vim.lsp.enable("pyright")
vim.lsp.enable("ccls")
