-- Autocommands
--
-- local modes = require("modes")

-- enter Word Processor mode
-- vim.api.nvim_exec([[
-- 	augroup filetype_vim
-- 		autocmd!
-- 		autocmd FileType txt
-- 		call WordProcessor()
-- 	augroup END
-- ]], false)

-- Spelling
--- Enable spell check for .md and .txt files
-- vim.cmd("autocmd BufRead,BufNewFile *.md,*.txt,*.norg setlocal spell")

-- Set the cursor line to have a line at the bottom
vim.cmd([[
	autocmd BufEnter * highlight CursorLine gui=underline
]])

-- Highlight on yank
vim.cmd([[
	augroup YankHighlight
		autocmd!
		autocmd TextYankPost * silent! lua vim.highlight.on_yank()
	augroup end
]])

-- Turn off cursor when changing buffer
vim.cmd([[
	augroup cursor_off
		autocmd!
		autocmd WinLeave * set nocursorline nocursorcolumn
		autocmd WinEnter * set cursorline cursorcolumn
	augroup END
]])

-- DAP
-- Autocompletion
vim.cmd([[
  au FileType dap-repl lua require('dap.ext.autocompl').attach()
]])

-- disable IBL plugin on Markdown files
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "markdown" },
  command = "IBLDisable",
})
--
-- Conceal in Neorg
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = { "*.norg" },
  command = "set conceallevel=3",
})

-- C files
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "c",
--   callback = function()
--     vim.bo.expandtab = false
--     vim.bo.tabstop = 2
--     vim.bo.shiftwidth = 2
--     vim.bo.softtabstop = 2
--   end,
-- })

-- Hyprlang LSP
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = { "*.hl", "hypr*.conf" },
  callback = function(event)
    print(string.format("starting hyprls for %s", vim.inspect(event)))
    vim.lsp.start({
      name = "hyprlang",
      cmd = { "hyprls" },
      root_dir = vim.fn.getcwd(),
    })
  end,
})
