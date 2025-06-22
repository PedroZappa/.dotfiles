local M = {}

-- Configuration
M.config = {
  model = "qwen3:14b",
  prompt = "GENERATE A COMPLETE CONCISE GIT COMMIT MESSAGE BASED ON THIS DIFF",
  split_height = 100,
  split_width = 25,
  split_dir = "vertical", -- or "horizontal"
  timeout = 30000, -- 30 seconds timeout
}

-- Helper function to check if we're in a git repository
local function is_git_repo()
  local git_dir = vim.fn.finddir(".git", ".;")
  return git_dir ~= ""
end

-- Helper function to check if ollama is available
local function is_ollama_available()
  local handle = io.popen("which ollama 2>/dev/null")
  local result = handle:read("*a")
  handle:close()
  return result ~= ""
end

-- Helper function to escape shell arguments
local function escape_shell_arg(arg)
  return "'" .. arg:gsub("'", "'\"'\"'") .. "'"
end

-- Build the ollama command with proper string formatting
local function build_ollama_command(model, prompt)
  local escaped_prompt = escape_shell_arg(prompt)
  return string.format("cat .git/COMMIT_EDITMSG | ollama run %s %s", model, escaped_prompt)
end

--
-- Main commit function
--
function M.commit(opts)
  opts = opts or {}

  -- Merge user options with defaults
  local config = vim.tbl_deep_extend("force", M.config, opts)

  -- Validate environment
  if not is_git_repo() then
    vim.notify("Error: Not in a git repository", vim.log.levels.ERROR)
    return false
  end

  if not is_ollama_available() then
    vim.notify("Error: Ollama is not available in PATH", vim.log.levels.ERROR)
    return false
  end

  -- Check if there are changes to commit
  local status_output = vim.fn.system("git status --porcelain")
  if status_output == "" then
    vim.notify("No changes to commit", vim.log.levels.WARN)
    return false
  end

  -- Stage all changes
  local add_result = vim.fn.system("git add .")
  if vim.v.shell_error ~= 0 then
    vim.notify("Error staging changes: " .. add_result, vim.log.levels.ERROR)
    return false
  end

  -- vim.cmd("Git commit --verbose")
  vim.cmd(string.format("belowright %dvsplit | Git commit --verbose", config.split_height))


  -- Create horizontal split with specified height
  vim.cmd(string.format("belowright %dsplit | terminal", config.split_height))

  -- Get the terminal buffer and job id
  local buf = vim.api.nvim_get_current_buf()
  local job_id = vim.b[buf].terminal_job_id

  if not job_id then
    vim.notify("Error: Failed to get terminal job ID", vim.log.levels.ERROR)
    return false
  end

  -- Prepare commands
  local enter = vim.api.nvim_replace_termcodes("<CR>", true, true, true)
  local commands = {
    "clear",
    build_ollama_command(config.model, config.prompt),
  }

  -- Execute commands in terminal
  vim.defer_fn(function()
    for _, cmd in ipairs(commands) do
      vim.fn.chansend(job_id, cmd .. "\n")
      vim.defer_fn(function() end, 100) -- Small delay between commands
    end
  end, 100)

  -- Enter terminal mode
  vim.cmd("startinsert")

  vim.notify("Commit message generation started...", vim.log.levels.INFO)
  return true
end

-- Setup function to configure the module
function M.setup(user_config)
  M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
end

-- Convenience function with different models
function M.commit_with_model(model, prompt)
  return M.commit({
    model = model,
    prompt = prompt or M.config.prompt,
  })
end

-- Quick commit with different prompts
function M.quick_commit()
  return M.commit({
    prompt = "write a short, concise commit message",
  })
end

function M.detailed_commit()
  return M.commit({
    prompt = "write a detailed commit message with explanation of changes",
  })
end

return M
