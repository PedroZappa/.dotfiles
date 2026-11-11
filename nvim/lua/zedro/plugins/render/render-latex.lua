return {
  "techwizrd/render-latex.nvim",
  ft = "markdown",
  opts = {},
  config = function()
    require("render_latex").setup({
      render = {
        preset = "compact", -- "compact" or "presentation"
        inline = "conceal", -- "content", "highlight", or false
        inline_symbols = true,
        live_preview = true,
        hide_on_cmdline = false,
        padding = 20,
      },
    })
  end
}
