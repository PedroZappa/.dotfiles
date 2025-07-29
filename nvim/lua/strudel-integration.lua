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
  else -- Fallback
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
-- 3. SERVER HEALTH & CONNECTION ----------------------------------
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

function M.connect_neovim()
  notify("Connecting to Neovim …")
  curl_async("POST", "/api/neovim/connect", "", function(ok, data)
    if not ok then
      return notify("❌ Neovim connect failed", vim.log.levels.ERROR)
    end
    local res = vim.fn.json_decode(data)
    notify(res.message or "Unknown response")
    if res.success then
      M.refresh_files()
    end
    -- local s = vim.fn.json_decode(data)
    -- s.neovim = true
  end)
end

function M.nvim_status()
  curl_async("GET", "/api/neovim/status", nil, function(ok, data)
    if ok then
      notify(data)
    else
      notify("Neovim status error", vim.log.levels.ERROR)
    end
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
    vim.pretty_print(list) -- interactive view
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

-- open file content in new scratch buffer
function M.open_file(path)
  local ep = "/api/file/" .. vim.fn.escape(path, "/")
  curl_async("GET", ep, nil, function(ok, data)
    if not ok then
      return notify("Cannot fetch " .. path, vim.log.levels.ERROR)
    end
    local f = vim.fn.json_decode(data)
    vim.cmd("new " .. f.name)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(f.content, "\n"))
    notify("Opened " .. path)
  end)
end

-- save current buffer back to server
function M.save_buffer()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == "" then
    return notify("Buffer has no name", vim.log.levels.WARN)
  end
  local rel = vim.fn.fnamemodify(bufname, ":.")
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local body = json_encode({ content = table.concat(lines, "\n") })
  local ep = "/api/file/" .. vim.fn.escape(rel, "/")
  curl_async("PUT", ep, body, function(ok, data)
    local res = ok and vim.fn.json_decode(data) or {}
    if res.success then
      notify("💾 Saved " .. rel)
    else
      notify("Save failed", vim.log.levels.ERROR)
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

function M.browser_status()
  curl_async("GET", "/api/browser/status", nil, function(ok, data)
    if ok then
      notify(data)
    else
      notify("Browser status error", vim.log.levels.ERROR)
    end
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
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  M.ensure_socket_server()

  local cmd = vim.api.nvim_create_user_command
  cmd("StrudelHealth", M.health, {})
  cmd("StrudelConnect", M.connect_neovim, {})
  cmd("StrudelNvimStat", M.nvim_status, {})
  cmd("StrudelFiles", M.file_list, {})
  cmd("StrudelRefresh", M.refresh_files, {})
  cmd("StrudelOpen", function(o)
    M.open_file(o.args)
  end, { nargs = 1, complete = "file" })
  cmd("StrudelSave", M.save_buffer, {})
  cmd("StrudelBrowser", M.browser_init, {})
  cmd("StrudelBStat", M.browser_status, {})
  cmd("StrudelStop", M.stop_strudel, {})
  cmd("StrudelSendBuf", M.send_buffer, {})

  -- Handy keymaps
  vim.keymap.set("n", "<leader>ss", M.send_buffer, { desc = "Strudel: send buffer" })
  vim.keymap.set("n", "<leader>sh", M.stop_strudel, { desc = "Strudel: hush/stop" })
  vim.keymap.set("n", "<leader>si", M.browser_init, { desc = "Strudel: init browser" })
end

return M
