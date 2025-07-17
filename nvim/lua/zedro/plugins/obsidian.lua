-- https://github.com/obsidian-nvim/obsidian.nvim?tab=readme-ov-file
local vault_path = "~/Documents/Zedros-Vault"
return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  -- ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  event = function()
    return {
      "BufReadPre " .. vim.fn.expand(vault_path) .. "/*.md",
      "BufNewFile " .. vim.fn.expand(vault_path) .. "/*.md",
    }
  end,
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",

    -- see above for full list of optional dependencies ☝️
  },
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    workspaces = {
      {
        name = "~/Documents/Zedros-Vault",
        path = vault_path,
      },
      {
        name = "work",
        path = "~/vaults/work",
      },
    },

    -- see below for full list of options 👇
  },
}
