-- Prevent re-running if already loaded
if vim.b.did_ftplugin then
  return
end
vim.b.did_ftplugin = 1

-- Debug: Confirm script is running
print("ftplugin/conf.lua loaded")

-- Disable legacy syntax highlighting
vim.bo.syntax = 'off'

-- Register the 'bash' parser for 'conf' filetype
vim.treesitter.language.register('bash', 'conf')

-- Configure Tree-sitter highlighting
require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true,
    disable = function(lang, buf)
      -- Only enable for 'conf' filetype
      return vim.bo[buf].filetype ~= 'conf'
    end,
    additional_vim_regex_highlighting = false,
  },
}

-- Explicitly load the custom query file
-- local query_path = vim.fn.stdpath('config') .. '/queries/conf/highlights.scm'
-- if vim.fn.filereadable(query_path) == 1 then
--   vim.treesitter.query.set('conf', 'highlights', vim.fn.readfile(query_path))
--   print("Loaded custom highlights.scm for conf")
-- else
--   print("Failed to find " .. query_path)
-- end

-- Folding options
vim.opt_local.foldmethod = 'marker'
vim.opt_local.foldmarker = '{,}'
