-- strudel-integration.lua – Neovim plugin for complete Strudel server control
-- Put this file in ~/.config/nvim/lua/… and `require` it from init.lua

local M = {}

-- Add debug flag
M.debug = true -- Set to false in production

local function debug_log(msg)
  if M.debug then
    vim.notify("🐛 [Strudel Debug] " .. msg, vim.log.levels.INFO)
  end
end

--------------------------------------------------------------------
-- 1. CONFIG -------------------------------------------------------
--------------------------------------------------------------------
M.config = {
  server_url = "http://localhost:3001",
  timeout = 5000, -- ms
  show_notifications = true,
  nvim_socket = "/tmp/strudel-nvim-socket",
  playing = false,
}

---@class ParserConfig
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.strudel = {
  install_info = {
    -- url = "https://github.com/pedrozappa/tree-sitter-strdl", -- local path or git repo
    url = "~/C0D3/AUDIO/tree-sitter-strdl/", -- local path
    files = { "src/parser.c" },              -- note that some parsers also require src/scanner.c or src/scanner.cc
    -- optional entries:
    branch = "main",                         -- default branch in case of git repo if different from master
    generate_requires_npm = false,           -- if stand-alone parser without npm dependencies
    requires_generate_from_grammar = false,  -- if folder contains pre-generated src/parser.c
  },
  filetype = "strdl",                        -- if filetype does not match the parser name
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
  debug_log(string.format("Making %s request to: %s", method, url))
  debug_log(string.format("Current playing state: %s", tostring(M.config.playing)))

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

    debug_log(string.format("Request completed - OK: %s, Code: %s", tostring(ok), tostring(obj.code)))
    debug_log(string.format("Response data: %s", data or "nil"))

    if cb then
      vim.schedule(function()
        cb(ok, data)
      end)
    end
  end

  if vim.system then
    vim.system(args, { text = true, timeout = M.config.timeout }, on_exit)
  else
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

-- Enhanced toggle function with debugging
function M.toggle_strudel()
  debug_log("=== TOGGLE FUNCTION CALLED ===")
  debug_log(string.format("Current state before toggle: playing = %s", tostring(M.config.playing)))

  if M.config.playing then
    debug_log("State indicates PLAYING - will attempt to STOP")
    notify("Stopping Strudel Playback")
    M.stop_strudel()
  else
    debug_log("State indicates STOPPED - will attempt to START")
    notify("Starting Strudel Playback")
    M.start_strudel()
  end
end

-- Enhanced start function with state management
function M.start_strudel()
  debug_log("=== START FUNCTION CALLED ===")
  notify("Starting Strudel")

  curl_async("POST", "/api/browser/start", "", function(ok, data)
    debug_log(string.format("Start request callback - OK: %s", tostring(ok)))

    if not ok then
      debug_log("Start request failed - server error")
      notify("Strudel start failed - server error", vim.log.levels.ERROR)
      return
    end

    if not data or data == "" then
      debug_log("Start request failed - empty response")
      notify("Strudel start failed - empty response", vim.log.levels.ERROR)
      return
    end

    -- Handle non-JSON responses
    if not data:match("^%s*[{%[]") then
      debug_log(string.format("Start request failed - non-JSON response: %s", data))
      notify("Strudel start failed: " .. data, vim.log.levels.ERROR)
      return
    end

    local success, res = pcall(vim.fn.json_decode, data)
    if not success then
      debug_log("Start request failed - invalid JSON response")
      notify("Strudel start failed - invalid JSON response", vim.log.levels.ERROR)
      return
    end

    debug_log(string.format("Start response parsed successfully: %s", vim.inspect(res)))

    if res and res.success then
      M.config.playing = true
      debug_log(string.format("State updated: playing = %s", tostring(M.config.playing)))
      notify(res.message or "Strudel started")
    else
      debug_log("Start request returned unsuccessful response")
      notify(res and res.message or "Strudel start failed", vim.log.levels.ERROR)
    end
  end)
end

-- Enhanced stop function with state management
function M.stop_strudel()
  debug_log("=== STOP FUNCTION CALLED ===")

  local fallback = function()
    debug_log("Using fallback /api/hush endpoint")
    curl_async("POST", "/api/hush", "", function(ok2)
      debug_log(string.format("Fallback request callback - OK: %s", tostring(ok2)))
      if ok2 then
        M.config.playing = false
        debug_log(string.format("State updated via fallback: playing = %s", tostring(M.config.playing)))
        notify("⏹️ Strudel stopped")
      else
        debug_log("Fallback request also failed")
        notify("Stop failed", vim.log.levels.ERROR)
      end
    end)
  end

  curl_async("POST", "/api/browser/stop", "", function(ok, data)
    debug_log(string.format("Stop request callback - OK: %s", tostring(ok)))

    if not ok then
      debug_log("Stop request failed - using fallback")
      return fallback()
    end

    if not data or data == "" or not data:match("^%s*[{%[]") then
      debug_log("Stop request returned empty/non-JSON - using fallback")
      return fallback()
    end

    local success, res = pcall(vim.fn.json_decode, data)
    if not success then
      debug_log("Stop request JSON parsing failed - using fallback")
      return fallback()
    end

    debug_log(string.format("Stop response parsed successfully: %s", vim.inspect(res)))

    if res and res.success then
      M.config.playing = false
      debug_log(string.format("State updated: playing = %s", tostring(M.config.playing)))
      notify(res.message)
    else
      debug_log("Stop request returned unsuccessful response - using fallback")
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
-- 8. DEBUG ----------------------------------------
--------------------------------------------------------------------
function M.debug_state()
  debug_log("=== STATE DEBUG ===")
  debug_log(string.format("Current playing state: %s", tostring(M.config.playing)))
  debug_log(string.format("Server URL: %s", M.config.server_url))
  debug_log(string.format("Timeout: %s", M.config.timeout))
  notify(string.format("Playing: %s", tostring(M.config.playing)))
end

function M.check_server_health()
  debug_log("=== TESTING SERVER HEALTH ===")
  M.health()
end

--------------------------------------------------------------------
-- 9. SETUP & COMMANDS --------------------------------------------
--------------------------------------------------------------------
local strudel_subcommands = {
  browser = { fn = M.browser_init, desc = "Start browser" },
  sendbuf = { fn = M.send_buffer, desc = "Send buffer" },
  toggle = { fn = M.toggle_strudel, desc = "Toggle Strudel Playback" },
  files = { fn = M.file_list, desc = "List files" },
  refresh = { fn = M.refresh_files, desc = "Refresh files" },
  debug = { fn = M.debug_state, desc = "Show Strudel state" },
  health = { fn = M.health, desc = "Show Strudel health" },
  teststart = { fn = M.start_strudel, desc = "Force start" },
  teststop = { fn = M.stop_strudel, desc = "Force stop" },
}

local function strudel_cmd(opts)
  local sub = opts.fargs[1]
  if not sub then
    vim.notify(
      "Strudel subcommand required. Available: " .. table.concat(vim.tbl_keys(strudel_subcommands), ", "),
      vim.log.levels.ERROR
    )
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
  desc = "Strudel command group",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "strdl",
  callback = function(args)
    local bufnr = args.buf
    vim.keymap.set("n", "<leader>ss", M.send_buffer, { buffer = bufnr, desc = "Strudel: send buffer" })
    vim.keymap.set("n", "<leader>sh", M.stop_strudel, { buffer = bufnr, desc = "Strudel: hush/stop" })
    vim.keymap.set("n", "<leader>st", M.toggle_strudel, { buffer = bufnr, desc = "Strudel: toggle" })
    vim.keymap.set("n", "<leader>si", M.browser_init, { buffer = bufnr, desc = "Strudel: init browser" })
    vim.keymap.set("n", "<leader>sd", M.debug_state, { buffer = bufnr, desc = "Strudel: debug state" })
    vim.keymap.set("n", "<leader>sH", M.check_server_health, { buffer = bufnr, desc = "Strudel: check health" })
  end,
})

-- Define colors for Strudel function categories
function M.setup_strudel_highlights()
  -- Core control functions - bright cyan for system-level controls
  vim.api.nvim_set_hl(0, "@function.control", {
    fg = "#4ecdc4", -- bright cyan
    -- bg = "",
    bold = true,
    -- italic = false,
    -- underline = false,
    -- strikethrough = false,
    -- reverse = false,
    -- standout = false,
  })

  -- Audio functions - warm orange for sound generation
  vim.api.nvim_set_hl(0, "@function.audio", {
    fg = "#ff8c42", -- warm orange
    bold = false,
  })

  -- Pattern generation functions - purple for creative operations
  vim.api.nvim_set_hl(0, "@function.pattern", {
    fg = "#a855f7", -- purple
    italic = true,
  })

  -- Effects functions - yellow/gold for audio processing
  vim.api.nvim_set_hl(0, "@function.effect", {
    fg = "#f59e0b", -- golden yellow
    bold = false,
  })

  -- Envelope functions - pink/magenta for amplitude control
  vim.api.nvim_set_hl(0, "@function.envelope", {
    fg = "#ec4899", -- pink
    italic = true,
  })

  -- Time manipulation functions - green for temporal operations
  vim.api.nvim_set_hl(0, "@function.time", {
    fg = "#10b981", -- emerald green
    bold = true,
  })

  -- Utility functions - light blue for helper functions
  vim.api.nvim_set_hl(0, "@function.utility", {
    fg = "#38bdf8", -- sky blue
    bold = false,
  })

  -- MIDI functions - red for hardware communication
  vim.api.nvim_set_hl(0, "@function.midi", {
    fg = "#ef4444", -- red
    bold = true,
  })

  -- Sample manipulation functions - teal for sample operations
  vim.api.nvim_set_hl(0, "@function.sample", {
    fg = "#14b8a6", -- teal
    italic = false,
  })
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  M.ensure_socket_server()

  -- Call the function to apply highlights
  M.setup_strudel_highlights()
end

return M
