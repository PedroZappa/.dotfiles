return {
  'brenoprata10/nvim-highlight-colors',
  event = 'VeryLazy',
  config = function()
    require('nvim-highlight-colors').setup {
      render = 'background',
    }
    -- require("cmp").setup({
    --   formatting = {
    --     format = require("nvim-highlight-colors").format
    --   }
    -- })
  end,

}
