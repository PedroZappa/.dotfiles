return {
  "monok-robeto/nvim.sfx_player",
  main = "nvim.sfx_player", -- lazy's auto-detection resolves to "nvim" (module lives under lua/nvim/sfx_player/)
  event = "VeryLazy",
  opts = {}, -- same as calling require("nvim.sfx_player").setup{}
}
