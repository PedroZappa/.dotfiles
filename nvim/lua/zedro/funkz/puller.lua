local M = {}

--- @brief Simulates summarization of git commit logs.
---
--- This function is a placeholder for the actual AvanteAsk integration.
--- It prefixes the logs with a summary header. In practice, replace this
--- with a call to your summarization API.
---
--- @param logs string: The git commit logs to summarize.
--- @return string: The summarized commit message.
local function summarize_commits(logs)
  -- For a poetic touch, we simply prefix with a summary header.
  local summary = "Summary of Recent Changes:\n\n"
  -- In practice, call your summarization API here, e.g., via vim.loop or plenary's async functions.
  summary = summary .. logs
  return summary
end

--- @brief Automates the process of pulling, logging, and summarizing git commits.
---
--- This function performs the following steps:
--- 1. Executes 'git pull' in the background.
--- 2. Fetches verbose git logs since the last pull.
--- 3. Summarizes the logs using a summarization function.
--- 4. Opens a new buffer in Neovim and inserts the summary.
local function GitCommitPullMergeMsgWriter()
  -- Step 1: Run 'git pull' in the background.
  vim.fn.jobstart({ "git", "pull" }, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_exit = function(job_id, pull_exit)
      if pull_exit == 0 then
        -- Step 2: Fetch verbose git logs since the last pull.
        -- We use ORIG_HEAD here as a reference to the previous HEAD.
        vim.fn.jobstart({ "git", "log", "ORIG_HEAD..HEAD", "--pretty=format:%h - %an: %s (%ci)" }, {
          stdout_buffered = true,
          stderr_buffered = true,
          on_exit = function(job_id, log_exit, event)
            if log_exit == 0 then
              -- Get the log output.
              local logs = table.concat(vim.fn.jobwait({ job_id }, 5000)[1], "\n")
              -- Step 3: Pass the logs to AvanteAsk (or any summarizer) to create a commit message.
              local summary = summarize_commits(logs)
              -- Step 4: Open a new buffer and insert the summary.
              vim.schedule(function()
                vim.cmd("enew")
                vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(summary, "\n"))
                print("Commit message buffer ready!")
              end)
            else
              print("Failed to retrieve git log data.")
            end
          end,
        })
      else
        print("Git pull failed; please check your repository status.")
      end
    end,
  })
end

-- Create a Neovim user command to run our function.
vim.api.nvim_create_user_command("GitMergeMsgWriter", GitCommitPullMergeMsgWriter, {})


return M
