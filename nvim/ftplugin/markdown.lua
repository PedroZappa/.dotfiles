--- Removes the ••• part.
vim.o.fillchars = "fold: ";

vim.o.foldmethod = "expr";
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()";

--- Disables fold text.
vim.o.foldtext = "";
