return {
  "monkoose/neocodeium",
  event = "VeryLazy",
  -- event = { "BufReadPre", "BufNewFile" },
  config = function()
    local neocodeium = require("neocodeium")
    local blink = require("blink.cmp")
    neocodeium.setup({
      -- If `false`, then would not start codeium server (disabled state)
      -- You can manually enable it at runtime with `:NeoCodeium enable`
      enabled = true,
      -- Path to a custom Codeium server binary (you can download one from:
      -- https://github.com/Exafunction/codeium/releases)
      bin = nil,
      -- When set to `true`, autosuggestions are disabled.
      -- Use `require'neodecodeium'.cycle_or_complete()` to show suggestions manually
      manual = false,
      -- Set to `false` to disable showing the number of suggestions label in the line number column
      show_label = true,
      -- Set to `true` to enable suggestions debounce
      debounce = false,
      -- Maximum number of lines parsed from loaded buffers (current buffer always fully parsed)
      -- Set to `0` to disable parsing non-current buffers (may lower suggestion quality)
      -- Set it to `-1` to parse all lines
      max_lines = 10000,
      -- Set to `true` to disable some non-important messages, like "NeoCodeium: server started..."
      silent = false,
      -- Set to a function that returns `true` if a buffer should be enabled
      -- and `false` if the buffer should be disabled
      -- You can still enable disabled by this option buffer with `:NeoCodeium enable_buffer`
      filter = function()
        return not blink.is_visible()
      end,
      -- filter = function(bufnr)
      --   -- Check if the buffer is a neo-tree buffer
      --   local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
      --   if filetype == "neo-tree" or fyletype == "Nui" then
      --     vim.cmd("Neocodeium disable")
      --     return false
      --   end
      --   return true
      -- end,
      -- Set to `false` to disable suggestions in buffers with specific filetypes
      -- You can still enable disabled by this option buffer with `:NeoCodeium enable_buffer`
      filetypes = {
        help = false,
        gitcommit = false,
        gitrebase = false,
        ["."] = false,
      },
      -- List of directories and files to detect workspace root directory for Codeium chat
      root_dir = { ".bzr", ".git", ".hg", ".svn", "_FOSSIL_", "package.json" },
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = "BlinkCmpMenuOpen",
      callback = function()
        neocodeium.clear()
      end,
    })
    -- Keybinds
    vim.keymap.set("i", "<C-g>", function()
      require("neocodeium").accept()
    end)
    vim.keymap.set("i", "<C-w>", function()
      require("neocodeium").accept_word()
    end)
    vim.keymap.set("i", "<C-l>", function()
      require("neocodeium").accept_line()
    end)
    vim.keymap.set("i", "<C-e>", function()
      require("neocodeium").cycle_or_complete()
    end)
    vim.keymap.set("i", "<C-r>", function()
      require("neocodeium").cycle_or_complete(-1)
    end)
    vim.keymap.set("i", "<C-x>", function()
      require("neocodeium").clear()
    end)
  end,
}
