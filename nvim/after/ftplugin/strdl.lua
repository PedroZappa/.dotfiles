local capabilities = vim.lsp.protocol.make_client_capabilities()

vim.lsp.set_log_level("debug")

vim.lsp.start({
  name = "strudel-lsp",
  cmd = {
    "npx",
    "ts-node",
    vim.fn.expand("~/C0D3/AUDIO/strudel-lsp-server/server/src/server.ts"),
    "--stdio",
  },
  filetypes = { "strudel" },
  root_dir = vim.fs.root(0, { ".git", "package.json" }),
  capabilities = capabilities,
})
