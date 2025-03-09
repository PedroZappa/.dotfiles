local M = {}

function M.commit()
  -- Stage all changes
  vim.cmd("Git add .")

  -- Open verbose commit buffer (this opens the diff buffer)
  vim.cmd("Git commit --verbose")

  -- Wait briefly for the buffer to load
  vim.defer_fn(function()
    -- Get current buffer content (diff) to provide context
    local diff_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")

    -- Define a direct and unambiguous prompt
    local commit_prompt = [[
GENERATE A COMPLETE GIT COMMIT MESSAGE BASED ON THIS DIFF, COMMIT & PUSH:

]] .. diff_content .. [[

IMPORTANT: DO NOT explain how to write commit messages. DO NOT provide instructions or explanations.
JUST WRITE THE ACTUAL COMMIT MESSAGE FOLLOWING THIS FORMAT:

type(scope): subject

body explaining what and why (not how)

Any footer references

EXAMPLES OF GOOD RESPONSES:
"feat(auth): add JWT authentication

Implement secure token-based authentication to replace session cookies.
This improves security and enables better scaling across services.

Closes #123"

OR

"fix(ui): resolve button alignment in mobile view

Buttons were misaligned on screens smaller than 768px due to
conflicting flex properties.

Fixes #456"
]]
    -- Escape single quotes in the prompt string
    local escaped_prompt = commit_prompt:gsub("'", "\\'")

    -- Pass the complete prompt safely escaped
    vim.cmd(":AvanteAsk '" .. escaped_prompt .. "'")
  end, 100) -- Small delay to ensure buffer is loaded
  -- Pass the complete prompt including diff content safely escaped
end

return M
