return {
  'ecthelionvi/NeoColumn.nvim',
  event = "BufReadPre",
  opts = {
    fg_color = "",
    bg_color = "",
    NeoColumn = "80",
    always_on = true,
    custom_NeoColumn = {
      markdown = "88",
    },
    -- excluded_ft = { "text", "markdown" },
  },
  vim.keymap.set("n", "<leader>nc", "<cmd>ToggleNeoColumn<cr>", { noremap = true, silent = true }),
}
