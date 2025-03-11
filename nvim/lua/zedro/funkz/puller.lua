local M = {}

function M.view_pr_logs()
  -- Create a buffer for the logs
  vim.cmd("new")
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_name(buf, "PR_Logs")
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].swapfile = false

  -- Get the most recent merged PR with its commit info
  vim.fn.appendbufline(buf, "$", "Finding last merged PR...")
  local pr_cmd =
    [[gh pr list --state merged --json number,title,url,mergeCommit,mergedAt --limit 50 | jq -r 'sort_by(.mergedAt) | reverse | .[0]']]
  local pr_json = vim.fn.system(pr_cmd)

  -- Parse the JSON response
  local ok, pr_info = pcall(vim.fn.json_decode, pr_json)
  if not ok or not pr_info or not pr_info.mergeCommit then
    vim.fn.appendbufline(buf, "$", "Error: Could not find last merge commit using GitHub CLI.")
    return
  end

  -- Add Latest merged PR information to buffer
  local merge_commit = pr_info.mergeCommit.oid
  vim.fn.appendbufline(buf, "$", "")
  vim.fn.appendbufline(buf, "$", "-- Latest merged PR --")
  vim.fn.appendbufline(buf, "$", "PR #" .. pr_info.number .. ": " .. pr_info.title)
  vim.fn.appendbufline(buf, "$", "URL: " .. pr_info.url)
  vim.fn.appendbufline(buf, "$", "Merged at: " .. pr_info.mergedAt)
  vim.fn.appendbufline(buf, "$", "Merge commit: " .. merge_commit)

  -- Add current repository status
  local current_branch_cmd = "git rev-parse --abbrev-ref HEAD"
  local current_branch = vim.fn.system(current_branch_cmd):gsub("\n", "")
  local head_commit_cmd = "git rev-parse HEAD"
  local head_commit = vim.fn.system(head_commit_cmd):gsub("\n", "")

  vim.fn.appendbufline(buf, "$", "")
  vim.fn.appendbufline(buf, "$", "-- Current Status --")
  vim.fn.appendbufline(buf, "$", "Current branch: " .. current_branch)
  vim.fn.appendbufline(buf, "$", "HEAD commit: " .. head_commit)

  -- Get ONLY commits AFTER that PR merge (next PR content!)
  vim.fn.appendbufline(buf, "$", "")
  vim.fn.appendbufline(buf, "$", "-- Commits AFTER last merged PR (Next PR content) --")

  -- Corrected git log command to get commits after the merge commit
  local git_log_cmd = "git log " .. merge_commit .. "..HEAD --pretty=fuller"
  local git_logs = vim.fn.systemlist(git_log_cmd)

  if #git_logs > 0 then
    for _, line in ipairs(git_logs) do
      vim.fn.appendbufline(buf, "$", line)
    end
  else
    if head_commit == merge_commit then
      vim.fn.appendbufline(buf, "$", "HEAD is at the merge commit. No new commits have been made.")
    else
      vim.fn.appendbufline(buf, "$", "No commits found since the merge. Try checking other branches.")
    end
    return
  end
  -- Set git filetype for syntax highlighting
  vim.bo[buf].filetype = "git"

  -- PROGRAM AGENT - FIXED HERE!
  -- Get PR logs buffer content - using the correct buffer ID (buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local buffer_content = table.concat(lines, "\n")

  -- Define a direct prompt about the PR content
  local prompt = [[
GENERATE A COMPLETE GIT COMMIT MESSAGE BASED ON THIS DIFF:

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
]] .. buffer_content

  local escaped_prompt = prompt:gsub("'", "\\'")
  local one_line_prompt = escaped_prompt:gsub("\n", " "):gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
  -- Schedule the command to run after the buffer is displayed
  vim.schedule(function()
    -- Escape any special characters in the prompt
    local escaped_prompt = vim.fn.shellescape(one_line_prompt)
    -- Send to your AvanteAsk command
    vim.cmd("AvanteAsk " .. escaped_prompt)
  end)
end

-- Create a user command
vim.api.nvim_create_user_command("PRLogs", M.view_pr_logs, {})

return M
