return {
  "ruslan-kurchenko/nvim-beautiful-mermaid",
  dependencies = { "3rd/image.nvim" },
  config = function()
    require("image").setup({
      backend = "kitty",
      editor_only_render_when_focused = true,  -- Recommended for tmux
      integrations = { markdown = { enabled = false } },
    })
    require("beautiful_mermaid").setup({
      render = { target = "in_buffer", format = "svg", backend = "image" },
    })
  end,
}
