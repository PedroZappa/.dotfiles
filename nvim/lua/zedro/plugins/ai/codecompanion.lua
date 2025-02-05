return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "j-hui/fidget.nvim",
  },
  init = function()
    require("zedro.funkz.fidget-spinner"):init()
  end,
  config = function()
    require("codecompanion").setup({
      adapters = {
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {})
        end,
      },
      strategies = {
        chat = { adapter = "ollama", },
        inline = { adapter = "ollama" },
        agent = { adapter = "ollama" },
      },
    })
  end
}
