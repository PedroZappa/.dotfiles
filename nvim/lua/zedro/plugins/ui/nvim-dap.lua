local function find_python_binary()
  -- Get Neovim's builtin filesystem API ('uv' in Neovim 0.10+)
  local uv = vim.loop
  local cwd = vim.fn.getcwd()
  local python_candidates = {
    cwd .. "/.venv/bin/python",             -- Unix virtualenv
    cwd .. "/.venv/Scripts/python.exe",     -- Windows virtualenv
    vim.fn.expand("~/.pyenv/shims/python"), -- pyenv (Unix)
    "/usr/bin/python3",                     -- common system python (Unix)
    "/usr/bin/python",                      -- fallback (Unix)
    "python3",                              -- in $PATH
    "python",                               -- another fallback
  }
  for _, path in ipairs(python_candidates) do
    local stat = uv.fs_stat(path)
    if stat and stat.type == "file" then
      return path
    end
  end
  return nil
end

return {
  "mfussenegger/nvim-dap",
  event = "VeryLazy",
  dependencies = {
    -- UI
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    -- Dependency for ASIO
    "nvim-neotest/nvim-nio",
    -- Install debug adapters
    "williamboman/mason.nvim",
    "jay-babu/mason-nvim-dap.nvim",
    -- Telescope integration
    "nvim-telescope/telescope-dap.nvim",
    -- Language specific
    {
      "mfussenegger/nvim-dap-python",
      ft = "python",
      dependencies = {
        -- https://github.com/mfussenegger/nvim-dap
        "mfussenegger/nvim-dap",
        "rcarriga/nvim-dap-ui",
      },
      config = function(_, opts)
        local path = find_python_binary()
        require("dap-python").setup(uv)
      end,
      -- config = function()
      --   local path = vim.fn.getcwd() .. '/.venv/bin/python'
      --   require('dap-python').setup(path)
      -- end
    },
    {
      "Joakker/lua-json5",
      build = "./install.sh",
    },
  },
  config = function()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      print("nvim-dap not installed!")
      return
    end
    dap.defaults.fallback.terminal_win_cmd = "50vsplit new"
    dap.defaults.fallback.focus_terminal = true
    require("dap").set_log_level("INFO") -- Helps when configuring DAP, see logs with :DapShowLog
    local ui = require("dapui")
    local widgets = require("dap.ui.widgets")
    require("dap-python").setup("python")

    -- JSON5 Compatibility
    -- require('dap.ext.vscode').json_decode = require('json5').parse
    -- DAP Packages Setup
    -- https://github.com/jay-babu/mason-nvim-dap.nvim
    require("mason-nvim-dap").setup({
      automatic_installation = true, -- Attempts to set reasonable defaults
      ensure_installed = { "codelldm", "cppdbg", "bash", "python" },
      -- see :help mason-nvim-dap on how to create custom handlers
      handlers = {
        function(config)
          -- all sources with no handler get passed here

          -- Keep original functionality
          require("mason-nvim-dap").default_setup(config)
        end,
      },
    })

    local function toggle_dap_keys()
      dap_keys_enabled = not dap_keys_enabled

      if dap_keys_enabled then
        -- Enable DAP keymaps
        vim.keymap.set("n", "<C-C>", dap.continue, { desc = "DAP: Continue" })
        vim.keymap.set("n", "<C-s>", dap.step_into, { desc = "DAP: Step Into" })
        vim.keymap.set("n", "<C-n>", dap.step_over, { desc = "DAP: Step Over" })
        vim.keymap.set("n", "<C-o>", dap.step_out, { desc = "DAP: Step Out" })
        vim.keymap.set("n", "<C-p>", dap.step_back, { desc = "DAP: Step Back" })
        vim.keymap.set("n", "<leader>rd", dap.restart, { desc = "DAP: Restart" })
        vim.keymap.set("n", "<leader>B", function()
          dap.set_breakpoint(nil, nil, vim.fn.input("DAP: Breakpoint condition: "))
        end, { desc = "DAP: Set breakpoint w/ message" })
        vim.keymap.set("n", "<leader>dgb", dap.run_to_cursor, { desc = "DAP: Run to cursor" })
        vim.keymap.set("n", "<leader>d?", function()
          ui.eval(nil, { enter = true })
        end, { desc = "DAP: Evaluate expression under cursor" })
        vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "DAP: Run last" })
        vim.keymap.set("n", "v", function()
          widgets.hover()
        end)
        -- vim.keymap.set("n", "v", function() widgets.preview() end)
        vim.keymap.set("n", "<leader>df", function()
          widgets.center_float(widgets.frames)
        end)
        vim.keymap.set("n", "<leader>ds", function()
          widgets.center_float(widgets.scopes)
        end)
      else
        -- Disable DAP keymaps
        vim.keymap.del("n", "<C-C>")
        vim.keymap.del("n", "<C-s>")
        vim.keymap.del("n", "<C-n>")
        vim.keymap.del("n", "<C-o>")
        -- vim.keymap.del("n", "<C-P>")
        -- vim.keymap.del("n", "<C-r>")
        -- vim.keymap.del("n", "<C-\\>")
        vim.keymap.del("n", "<leader>B")
        vim.keymap.del("n", "<leader>dgb")
        vim.keymap.del("n", "<leader>d?")
        vim.keymap.del("n", "<leader>dl")
        vim.keymap.del("n", "<leader>rd")
        vim.keymap.del("n", "<leader>df")
        vim.keymap.del("n", "<leader>ds")
      end
    end

    -- Adapter Configurations
    -- dap.adapters.gdb       = {
    --   type = 'executable',
    --   command = 'gdb',
    --   args = { '--quiet', '--interpreter=dap' }
    -- }
    dap.adapters.python = {
      type = "executable",
      command = "python3",
      args = { "-m", "debugpy.adapter" },
    }

    -- Language Configurations
    -- https://sourceware.org/gdb/current/onlinedocs/gdb.html/Interpreters.html
    -- https://sourceware.org/gdb/current/onlinedocs/gdb.html/Debugger-Adapter-Protocol.html
    dap.configurations.c = {
      {
        name = "Run executable (GDB)",
        type = "gdb",
        request = "launch",
        -- This requires special handling of 'run_last', see
        -- https://github.com/mfussenegger/nvim-dap/issues/1025#issuecomment-1695852355
        program = function()
          return dap_utils.pick_file(exec_opts)
        end,
      },
      {
        name = "Run executable with arguments (GDB)",
        type = "gdb",
        request = "launch",
        -- This requires special handling of 'run_last', see
        -- https://github.com/mfussenegger/nvim-dap/issues/1025#issuecomment-1695852355
        program = function()
          local path = vim.fn.input({
            prompt = "Path to executable: ",
            default = vim.fn.getcwd() .. "/",
            completion = "file",
          })

          return (path and path ~= "") and path or dap.ABORT
        end,
        args = function()
          local arg_source = vim.fn.input("Load arguments from file (f) or enter as string (s)? ")
          local args = {}

          if arg_source:lower() == "f" then
            -- Load arguments from file
            local arg_file = vim.fn.input("Path to arguments file: ", vim.fn.getcwd() .. "/", "file")
            table.insert(args, arg_file)
          else
            local arg_str = vim.fn.input("Arguments: ")
            args = vim.split(arg_str, " ")
          end
          toggle_dap_keys()
        end,
      },
      {
        name = "Attach to process (GDB)",
        type = "gdb",
        request = "attach",
        processId = require("dap.utils").pick_process,
      },
      {
        name = "Run executable with arguments (codelldb)",
        type = "codelldb",
        request = "launch",
        -- This requires special handling of 'run_last', see
        -- https://github.com/mfussenegger/nvim-dap/issues/1025#issuecomment-1695852355
        program = function()
          local path = vim.fn.input({
            prompt = "Path to executable: ",
            default = vim.fn.getcwd() .. "/",
            completion = "file",
          })
          toggle_dap_keys()
          return (path and path ~= "") and path or dap.ABORT
        end,
        args = function()
          local arg_source = vim.fn.input("Load arguments from file (f) or enter as string (s)? ")
          local args = {}

          if arg_source:lower() == "f" then
            -- Load arguments from file
            local arg_file = vim.fn.input("Path to arguments file: ", vim.fn.getcwd() .. "/", "file")
            table.insert(args, arg_file)
          else
            local arg_str = vim.fn.input("Arguments: ")
            args = vim.split(arg_str, " ")
          end
        end,
      },
      {
        name = "(codelldb) Select and attach to process",
        type = "codelldb",
        request = "attach",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        pid = function()
          local name = vim.fn.input("Executable name (filter): ")
          return require("dap.utils").pick_process({ filter = name })
        end,
        cwd = "${workspaceFolder}",
      },
      {
        name = "Attach to codelldb :1234",
        type = "codelldb",
        request = "attach",
        target = "localhost:1234",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
      },
    }

    dap.configurations.cpp = {
      {
        name = "Run executable (GDB)",
        type = "gdb",
        request = "launch",
        -- This requires special handling of 'run_last', see
        -- https://github.com/mfussenegger/nvim-dap/issues/1025#issuecomment-1695852355
        program = function()
          return dap_utils.pick_file(exec_opts)
        end,
      },
      {
        name = "Run executable with arguments (GDB)",
        type = "gdb",
        request = "launch",
        -- This requires special handling of 'run_last', see
        -- https://github.com/mfussenegger/nvim-dap/issues/1025#issuecomment-1695852355
        program = function()
          local path = vim.fn.input({
            prompt = "Path to executable: ",
            default = vim.fn.getcwd() .. "/",
            completion = "file",
          })

          return (path and path ~= "") and path or dap.ABORT
        end,
        args = function()
          local arg_source = vim.fn.input("Load arguments from file (f) or enter as string (s)? ")
          local args = {}

          if arg_source:lower() == "f" then
            -- Load arguments from file
            local arg_file = vim.fn.input("Path to arguments file: ", vim.fn.getcwd() .. "/", "file")
            table.insert(args, arg_file)
          else
            local arg_str = vim.fn.input("Arguments: ")
            args = vim.split(arg_str, " ")
          end
          toggle_dap_keys()
        end,
      },
      {
        name = "Attach to process (GDB)",
        type = "gdb",
        request = "attach",
        processId = require("dap.utils").pick_process,
      },
      {
        name = "(codelldb) Launch",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = true,
        stopAtBeginningOfMainSubprogram = true,
      },
      {
        name = "Run executable with arguments (codelldb)",
        type = "codelldb",
        request = "launch",
        -- This requires special handling of 'run_last', see
        -- https://github.com/mfussenegger/nvim-dap/issues/1025#issuecomment-1695852355
        program = function()
          local path = vim.fn.input({
            prompt = "Path to executable: ",
            default = vim.fn.getcwd() .. "/",
            completion = "file",
          })

          return (path and path ~= "") and path or dap.ABORT
        end,
        args = function()
          local arg_source = vim.fn.input("Load arguments from file (f) or enter as string (s)? ")
          local args = {}

          if arg_source:lower() == "f" then
            -- Load arguments from file
            local arg_file = vim.fn.input("Path to arguments file: ", vim.fn.getcwd() .. "/", "file")
            table.insert(args, arg_file)
          else
            local arg_str = vim.fn.input("Arguments: ")
            args = vim.split(arg_str, " ")
          end
          toggle_dap_keys()
        end,
      },
      {
        name = "(codelldb) Select and attach to process",
        type = "codelldb",
        request = "attach",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        pid = function()
          local name = vim.fn.input("Executable name (filter): ")
          return require("dap.utils").pick_process({ filter = name })
        end,
        cwd = "${workspaceFolder}",
      },
      {
        name = "Attach to codelldb :1234",
        type = "codelldb",
        request = "attach",
        target = "localhost:1234",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
      },
    }

    dap.configurations.sh = {
      {
        type = "bashdb",
        request = "launch",
        name = "Launch Bash file",
        showDebugOutput = true,
        pathBashdb = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
        pathBashdbLib = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir",
        trace = true,
        file = "${file}",
        program = "${file}",
        cwd = "${workspaceFolder}",
        pathCat = "cat",
        pathBash = "/bin/bash",
        pathMkfifo = "mkfifo",
        pathPkill = "pkill",
        args = {},
        env = {},
        terminalKind = "integrated",
      },
    }

    local function getpid()
      local pid = require("dap.utils").pick_process({ filter = "python" })
      if type(pid) == "thread" then
        -- returns a coroutine.create due to it being run from fzf-lua ui.select
        -- start the coroutine and wait for `coroutine.resume` (user selection)
        coroutine.resume(pid)
        pid = coroutine.yield(pid)
      end

      return pid
    end
    dap.configurations.python = {
      {
        -- https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
        type = "python",
        request = "launch",
        name = "Launch file (zedro-py)",
        program = "${file}",
        -- module = function()
        --   local path = vim.fn.input({}, vim.fn.getcwd() .. '/', 'file')
        --   return (path and path ~= '') and path or dap.ABORT
        -- end,
        pythonPath = function()
          local cwd = vim.fn.getcwd()
          if vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
            return cwd .. "/.venv/bin/python"
          else
            return "/usr/bin/python3"
          end
        end,
        cwd = function()
          return vim.fn.getcwd()
        end,
        console = "integratedTerminal",
        logToFile = true,
        showReturnValue = true,
        -- stopOnEntry = true,
        args = function()
          local user_args = vim.fn.input("Arguments: ")
          return vim.split(user_args or "", " ")
        end,
      },
      {
        type = "python",
        request = "attach",
        name = "Attach to process",
        cwd = function()
          return vim.fn.getcwd()
        end,
        connect = function()
          -- https://github.com/microsoft/debugpy/#attaching-to-a-running-process-by-id
          local port = 5678
          local pid = getpid()
          local out = vim.fn.systemlist({
            python_prefix .. python_bin,
            "-m",
            "debugpy",
            "--listen",
            "localhost:" .. tostring(port),
            "--pid",
            tostring(pid),
          })
          assert(vim.v.shell_error == 0, table.concat(out, "\n"))
          return { port = port }
        end,
        logToFile = true,
      },
    }

    -- UI : see |:help nvim-dap-ui|
    vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "Character", linehl = "", numhl = "" })
    ui.setup({
      layouts = {
        {
          elements = {
            { id = "scopes",      size = 0.50 },
            { id = "breakpoints", size = 0.10 },
            { id = "stacks",      size = 0.25 },
            -- { id = "threads",     size = 0.10 },
            { id = "watches",     size = 0.15 },
          },
          size = 50,
          position = "left",
        },
        {
          elements = {
            { id = "repl",    size = 0.60 },
            { id = "console", size = 0.40 },
          },
          size = 0.25,
          position = "bottom",
        },
      },

      icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
      controls = {
        icons = {
          pause = "⏸",
          play = "▶",
          step_into = "⏎",
          step_over = "⏭",
          step_out = "⏮",
          step_back = "b",
          run_last = "▶▶",
          terminate = "⏹",
          disconnect = "⏏",
        },
      },
    })
    require("nvim-dap-virtual-text").setup({
      -- This just tries to mitigate the chance that I leak tokens here. Probably won't stop it from happening...
      display_callback = function(variable)
        local name = string.lower(variable.name)
        local value = string.lower(variable.value)
        if name:match("secret") or name:match("api") or value:match("secret") or value:match("api") then
          return "*****"
        end

        if #variable.value > 15 then
          return " " .. string.sub(variable.value, 1, 15) .. "... "
        end

        return " " .. variable.value
      end,
    })

    function get_element_id_at_cursor()
      local cursor = vim.api.nvim_win_get_cursor(0)
      local row, col = cursor[1] - 1, cursor[2]
      local buf = vim.api.nvim_get_current_buf()
      local parser = vim.treesitter.get_parser(buf)
      local tree = parser:parse()[1]
      local root = tree:root()
      local node = root:named_descendant_for_range(row, col, row, col)

      while node do
        if node:type() == "element_declaration" then
          local id_node = node:child(0)
          if id_node then
            return vim.treesitter.get_node_text(id_node, buf)
          end
        end
        node = node:parent()
      end

      return nil
    end

    -- require("ui").float_element(get_element_id_at_cursor())

    -- Run DAP w/ args function
    local function start_dap_with_args()
      local filetype = vim.bo.filetype
      -- Map filetypes to debug adapter types
      local adapter_map = {
        c = "codelldb",
        cpp = "codelldb",
        bash = "bash-debug-adapter",
        python = "debugpy",
        -- Add more mappings as needed
      }
      -- Get the debug adapter type for the current filetype
      local adapter_type = adapter_map[filetype]
      if not adapter_type then
        print("No debug adapter for filetype: " .. filetype)
        return
      end
      -- Check for makefile in the current working directory
      local makefile_exists = vim.fn.filereadable("makefile") == 1 or vim.fn.filereadable("Makefile") == 1
      if makefile_exists then
        -- Run make command
        local make_result = vim.fn.system("make")
        print(make_result)

        -- Check if make was successful
        if vim.v.shell_error ~= 0 then
          print("Make command failed. Do you want to continue? (y/n)")
          local continue = vim.fn.input(""):lower()
          if continue ~= "y" then
            print("Debugging cancelled.")
            return
          end
        end
      else
        print("No makefile found in the current directory. Skipping make command.")
      end
      -- Prompt user for program and arguments
      local program = vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")

      -- Ask if arguments are in a file or should be entered as a string
      local arg_source = vim.fn.input("Load arguments from file (f) or enter as string (s)? ")
      local args = {}

      if arg_source:lower() == "f" then
        -- Load arguments from file
        local arg_file = vim.fn.input("Path to arguments file: ", vim.fn.getcwd() .. "/", "file")
        table.insert(args, arg_file)
      else
        local arg_str = vim.fn.input("Arguments: ")
        args = vim.split(arg_str, " ")
      end

      local config = {
        type = adapter_type,
        request = "launch",
        program = program,
        args = args,
        cwd = "${workspaceFolder}",
      }
      dap.run(config)
    end
    local dap_keys_enabled = false

    -- Event Listeners
    dap.listeners.before.attach.dapui_config = function()
      ui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      ui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      toggle_dap_keys()
      ui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      toggle_dap_keys()
      ui.close()
    end
    dap.listeners.after.event_initialized["dapui_config"] = function()
      ui.open()
      toggle_dap_keys()
    end
    -- Global DAP keybinds
    vim.keymap.set("n", "<C-\\>", ui.toggle, { desc = "DAP: Check last session results" })
    vim.keymap.set("n", "<leader>tdk", toggle_dap_keys, { desc = "DAP: Toggle DAP keybinds" })
    vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
    vim.keymap.set("n", "<A-\\>", start_dap_with_args, { desc = "DAP: Start w/ Args" })

    vim.keymap.set("n", "<leader>pdo", function()
      if vim.bo.filetype == "python" then
        vim.api.nvim_command("PyrightOrganizeImports")
      end
    end, { desc = "DAP: Organize Imports" })

    vim.keymap.set("n", "<leader>pdc", function()
      if vim.bo.filetype == "python" then
        require("dap-python").test_class()
      end
    end, { desc = "DAP: Debug python class" })

    vim.keymap.set("n", "<leader>pdm", function()
      if vim.bo.filetype == "python" then
        require("dap-python").test_method()
      end
    end, { desc = "DAP: Debug python method" })

    vim.keymap.set("n", "<leader>pds", function()
      if vim.bo.filetype == "python" then
        require("dap-python").debug_selection()
      end
    end, { desc = "DAP: Debug python selection" })
  end,
}
