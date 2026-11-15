return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  -- `main` branch is a full rewrite (Nvim 0.12+); it does not support lazy-loading
  lazy = false,
  dependencies = {
    "OXY2DEV/markview.nvim",
    -- "nvim-treesitter/nvim-treesitter-textobjects",
    -- "nvim-treesitter/nvim-treesitter-context",
    -- "nvim-treesitter/nvim-treesitter-refactor", -- Provides "got to def" capabilities
    -- { "nushell/tree-sitter-nu", build = ":TSUpdate nu" },
  },
  build = ":TSUpdate",
  config = function()
    -- Legacy `ensure_installed` equivalents (the old `configs.setup` API is gone)
    require("nvim-treesitter").install({
      "nix",
      "c",
      "bash",
      "lua",
      "vim",
      "vimdoc",
      "query",
      "python",
      "javascript",
      "html",
      "markdown",
      "make",
      "http",
    })

    -- https://github.com/nvim-treesitter/nvim-treesitter-context
    -- require("treesitter-context").setup({
    --   enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
    --   max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
    --   min_window_height = 0,    -- Minimum number of lines the window should span
    --   line_numbers = true,
    --   multiline_threshold = 20, -- Maximum number of lines to show for a single context
    --   trim_scope = "outer",     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
    --   mode = "cursor",          -- Line used to calculate context. Choices: 'cursor', 'topline'
    --   -- Separator between context and content. Should be a single character string, like '-', or nil
    --   separator = nil,
    --   zindex = 20,     -- The Z-index of the context window
    --   on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
    -- })
    -- Jump to context
    vim.keymap.set("n", "[c", function()
      require("treesitter-context").go_to_context(vim.v.count1)
    end, { silent = true })
  end,
}
