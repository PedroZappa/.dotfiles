local M = {}

function M.commit()
  vim.cmd(":Git add .")
  vim.cmd(":Git commit --verbose")
  vim.cmd(":AvanteAsk 'Write a Conventional Commit message describing the changes in this diff'")
end

return M
