-- strudel-integration.lua – Neovim plugin for complete Strudel server control
-- Put this file in ~/.config/nvim/lua/… and `require` it from init.lua

local M = {}

--------------------------------------------------------------------
-- 1. CONFIG -------------------------------------------------------
--------------------------------------------------------------------
M.config = {
  server_url = "http://localhost:3001",
  timeout = 5000, -- ms
  show_notifications = true,
  nvim_socket = "/tmp/strudel-nvim-socket",
}

---@class ParserConfig
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.strudel = {
  install_info = {
    -- url = "https://github.com/pedrozappa/tree-sitter-strdl", -- local path or git repo
    url = "~/C0D3/AUDIO/tree-sitter-strdl/", -- local path
    files = { "src/parser.c" }, -- note that some parsers also require src/scanner.c or src/scanner.cc
    -- optional entries:
    branch = "main", -- default branch in case of git repo if different from master
    generate_requires_npm = false, -- if stand-alone parser without npm dependencies
    requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
  },
  filetype = "strdl", -- if filetype does not match the parser name
}

vim.api.nvim_create_autocmd("BufRead", {
  pattern = "*.strdl",
  callback = function()
    vim.bo.filetype = "strdl"
  end,
})

--------------------------------------------------------------------
-- 2. UTILITIES ----------------------------------------------------
--------------------------------------------------------------------
-- JSON encode shim (works on 0.8–0.10)
local json_encode = vim.json and vim.json.encode or vim.fn.json_encode

local function notify(msg, level)
  if M.config.show_notifications then
    vim.notify(msg, level or vim.log.levels.INFO)
  end
end

-- Asynchronous curl wrapper (uses vim.system if available, otherwise jobstart)
local function curl_async(method, endpoint, body, cb, content_type)
  local url = M.config.server_url .. endpoint
  local args = { "curl", "-s", "-X", method, "--max-time", tostring(M.config.timeout / 1000) }

  if body then
    local ct = content_type or "application/json"
    table.insert(args, "-H")
    table.insert(args, "Content-Type: " .. ct)
    table.insert(args, "--data-binary")
    table.insert(args, body)
  end
  table.insert(args, url)

  local on_exit = function(obj)
    local ok = (obj.code == 0)
    local data = (obj.stdout ~= "" and obj.stdout) or obj.stderr
    if cb then
      vim.schedule(function()
        cb(ok, data)
      end)
    end
  end

  if vim.system then -- Neovim ≥0.10
    vim.system(args, { text = true, timeout = M.config.timeout }, on_exit)
  else               -- Fallback
    vim.fn.jobstart(args, {
      stdout_buffered = true,
      on_exit = function(_, code, _)
        on_exit({ code = code, stdout = table.concat(vim.fn.jobwait({}), ""), stderr = "" })
      end,
      timeout = M.config.timeout,
    })
  end
end

--------------------------------------------------------------------
-- 3. SERVER HEALTH ------------------------------------------------
--------------------------------------------------------------------
function M.health()
  curl_async("GET", "/health", nil, function(ok, data)
    if not ok then
      return notify("Server unreachable", vim.log.levels.ERROR)
    end
    local s = vim.fn.json_decode(data)
    local msg = string.format(
      "Server:%s | Neovim:%s | Browser:%s | Files:%d",
      s.status,
      s.neovim and "🟢" or "🔴",
      s.browser and "🟢" or "🔴",
      s.files.count or 0
    )
    notify(msg)
  end)
end

--------------------------------------------------------------------
-- 4. FILE MANAGEMENT ---------------------------------------------
--------------------------------------------------------------------
function M.file_list()
  curl_async("GET", "/api/files", nil, function(ok, data)
    if not ok then
      return notify("File list failed", vim.log.levels.ERROR)
    end
    local list = vim.fn.json_decode(data)
    vim.notify("Files:\n" .. table.concat(list, "\n"), vim.log.levels.INFO)
  end)
end

function M.refresh_files()
  notify("Refreshing file cache …")
  curl_async("POST", "/api/files", "", function(ok, data)
    if ok then
      notify("File list refreshed")
    else
      notify("Refresh failed", vim.log.levels.ERROR)
    end
  end)
end

--------------------------------------------------------------------
-- 5. BROWSER / PLAYWRIGHT ----------------------------------------
--------------------------------------------------------------------
function M.browser_init()
  notify("Launching Strudel browser …")
  curl_async("POST", "/api/browser/init", "", function(ok, data)
    local res = ok and vim.fn.json_decode(data) or {}
    notify(res.message or "Browser init failed", res.success and nil or vim.log.levels.ERROR)
  end)
end

function M.stop_strudel()
  -- Prefer structured endpoint; fall back to /api/hush
  curl_async("POST", "/api/browser/stop", "", function(ok, data)
    local fallback = function()
      curl_async("POST", "/api/hush", "", function(ok2)
        if ok2 then
          notify("⏹️ Strudel stopped")
        else
          notify("Stop failed", vim.log.levels.ERROR)
        end
      end)
    end
    if not ok then
      return fallback()
    end
    local res = vim.fn.json_decode(data)
    if res.success then
      notify(res.message)
    else
      fallback()
    end
  end)
end

function M.browser_status()
  curl_async("GET", "/api/browser/status", nil, function(ok, data)
    if ok then
      notify(data)
    else
      notify("Browser status error", vim.log.levels.ERROR)
    end
  end)
end

--------------------------------------------------------------------
-- 6. CODE TRANSFER -----------------------------------------------
--------------------------------------------------------------------
local function post_code(code)
  local payload = json_encode({ code = code })
  curl_async("POST", "/api/browser/send-code", payload, function(ok, data)
    local res = ok and vim.fn.json_decode(data) or {}
    notify(res.message or "Code send failed", res.success and nil or vim.log.levels.ERROR)
  end)
end

function M.send_buffer()
  local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  if text:match("^%s*$") then
    return notify("Empty buffer", vim.log.levels.WARN)
  end
  notify("🚀 Sending buffer to Strudel …")
  post_code(text)
end

--------------------------------------------------------------------
-- 7. SOCKET SERVER HELPER ----------------------------------------
--------------------------------------------------------------------
function M.ensure_socket_server()
  if vim.v.servername ~= "" then
    return vim.v.servername
  end
  local srv = vim.fn.serverstart(M.config.nvim_socket)
  if srv ~= "" then
    notify("🔌 Neovim server: " .. srv)
  end
  return srv
end

--------------------------------------------------------------------
-- 8. SETUP & COMMANDS --------------------------------------------
--------------------------------------------------------------------
local strudel_subcommands = {
  sendbuf = { fn = M.send_buffer, desc = "Send buffer" },
  stop = { fn = M.stop_strudel, desc = "Stop Strudel" },
  browser = { fn = M.browser_init, desc = "Start browser" },
  health = { fn = M.health, desc = "Show Strudel health" },
  files = { fn = M.file_list, desc = "List files" },
  refresh = { fn = M.refresh_files, desc = "Refresh files" },
}

local function strudel_cmd(opts)
  local sub = opts.fargs[1]
  if not sub then
    vim.notify("Strudel subcommand required. Available: " .. table.concat(vim.tbl_keys(strudel_subcommands), ", "), vim.log.levels.ERROR)
    return
  end
  local handler = strudel_subcommands[sub:lower()]
  if not handler then
    vim.notify("Unknown Strudel subcommand: " .. sub, vim.log.levels.ERROR)
    return
  end
  handler.fn(opts)
end

local function strudel_complete(arg_lead, cmdline, cursor_pos)
  local words = vim.split(cmdline, "%s+")
  if #words <= 2 then
    -- Complete the subcommand name
    return vim.tbl_filter(function(key)
      return key:find(arg_lead, 1, true) == 1
    end, vim.tbl_keys(strudel_subcommands))
  end
  -- Optionally handle per-subcommand arg completion here
  return {}
end

vim.api.nvim_create_user_command("Strudel", strudel_cmd, {
  nargs = "+",
  complete = strudel_complete,
  desc = "Strudel command group"
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "strdl",
  callback = function(args)
    local bufnr = args.buf
    vim.keymap.set("n", "<leader>ss", M.send_buffer, { buffer = bufnr, desc = "Strudel: send buffer" })
    vim.keymap.set("n", "<leader>sh", M.stop_strudel, { buffer = bufnr, desc = "Strudel: hush/stop" })
    vim.keymap.set("n", "<leader>si", M.browser_init, { buffer = bufnr, desc = "Strudel: init browser" })
  end,
})

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  M.ensure_socket_server()
end

return M
