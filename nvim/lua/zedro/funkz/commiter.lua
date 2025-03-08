local M = {}

function M.commit()
  vim.cmd(":Git add .")
  vim.cmd(":Git commit --verbose")
  vim.cmd(":AvanteAsk 'Write a commit message describing the changes in this diff'")
end

return M
