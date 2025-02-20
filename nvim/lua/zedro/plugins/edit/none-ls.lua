return {
  "nvimtools/none-ls.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local null_ls = require("null-ls")
    local gitsigns = null_ls.builtins.code_actions.gitsigns.with({
      config = {
        filter_actions = function(title)
          return title:lower():match("blame") == nil       -- filter out blame actions
        end,
      },
    })

    null_ls.setup({
      sources = {
        gitsigns,
        null_ls.builtins.code_actions.refactoring,
        null_ls.builtins.completion.spell,
        -- null_ls.builtins.diagnostics.eslint,
        null_ls.builtins.diagnostics.codespell,
        null_ls.builtins.diagnostics.cmake_lint,
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.formatting.stylua,
      },
      border = nil,
      cmd = { "nvim" },
      debounce = 250,
      debug = false,
      default_timeout = 5000,
      diagnostic_config = {},
      diagnostics_format = "#{m}",
      fallback_severity = vim.diagnostic.severity.ERROR,
      log_level = "warn",
      notify_format = "[null-ls] %s",
      on_attach = nil,
      on_init = nil,
      on_exit = nil,
      root_dir = require("null-ls.utils").root_pattern(".null-ls-root", "Makefile", ".git"),
      root_dir_async = nil,
      should_attach = nil,
      temp_dir = nil,
      update_in_insert = false,
    })
  end,
}
