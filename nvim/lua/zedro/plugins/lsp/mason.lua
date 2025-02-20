return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  lazy = false,
  config = function()
    local lsp_zero = require("lsp-zero")
    local mason = require("mason")                     -- import mason
    local mason_lspconfig = require("mason-lspconfig") -- import mason-lspconfig
    local mason_tool_installer = require("mason-tool-installer")
    -- Python virtual env detection
    local util = require("lspconfig/util")
    local path = util.path

    local function file_exists(name)
      local f = io.open(name, "r")
      if f ~= nil then
        io.close(f)
        return true
      else
        return false
      end
    end

    local function get_python_path(workspace)
      -- Use activated virtualenv.
      if vim.env.VIRTUAL_ENV then
        return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
      end
      -- Find and use virtualenv in workspace directory.
      for _, pattern in ipairs({ "*", ".*" }) do
        local match = vim.fn.glob(path.join(workspace, pattern, "pyvenv.cfg"))
        if match ~= "" then
          return path.join(path.dirname(match), "bin", "python")
        end
      end
      local default_venv_path = path.join(vim.env.HOME, "virtualenvs", "nvim-venv", "bin", "python")
      if file_exists(default_venv_path) then
        return default_venv_path
      end
      -- Fallback to system Python.
      return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
    end

    -- Setup
    mason.setup({
      ui = {
        icons = {
          package_installed = "✔️",
          package_pending = "➿",
          package_uninstalled = "💤",
        },
      },
    })

    mason_tool_installer.setup({
      ensure_installed = {
        -- "nixfmt",   -- nix formatter
        "prettier", -- prettier formatter
        "stylua",   -- lua formatter
        -- "eslint_d", -- js linter
        "ruff",     -- python formatter
        -- "isort",    -- python import sorter
        -- "debugpy",  -- python debugger
      },
    })
    vim.api.nvim_command("MasonToolsInstall")

    mason_lspconfig.setup({
      ensure_installed = {
        "clangd",
        "lua_ls",
        -- "jsonls",                    -- json
        -- "html",                      -- html
        "pyright",                   -- python
      },
      automatic_installation = true, -- not the same as ensure_installed
      handlers = {
        -- this first function is the "default handler"
        -- it applies to every language server without a "custom handler"
        function(server_name)
          require("lspconfig")[server_name].setup({})
        end,
      },
      lsp_zero.default_setup,
      lua_ls = function()
        require("lspconfig").lua_ls.setup({
          cmd = { "/run/current-system/sw/bin/lua-language-server" },
          settings = {
            Lua = {
              formatting = {
                command = { "/run/current-system/sw/bin/stylua" },
              },
              format = {
                enable = true,
                defaultConfig = {
                  tab_width = 2,
                  indent_style = "space",
                  indent_width = 2,
                  continuation_indent = 2,
                },
              },
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                library = {
                  [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                  [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
                },
                maxPreload = 100000,
                preloadFileSize = 10000,
              },
            },
          },
        })
      end,
      clangd = function()
        require("lspconfig").clangd.setup({
          cmd = {
            "/run/current-system/sw/bin/clangd",
            "--compile-commands-dir=" .. vim.loop.cwd(),
            "--background-index",
            "--clang-tidy",
            "--suggest-missing-includes",
          },
          init_options = {
            clangdFileStatus = true,
            additionalIncludes = { project_include_dir },
            -- clangdFileWatched = true,
            fallbackFlags = {
              "-I" .. vim.loop.cwd() .. "/include", -- Custom include path
              "-I/usr/local/lib",                   -- System-wide include
            },
          },
          filetypes = { "c", "h", "hpp", "cpp", "objc", "objcpp" },
          cmd_env = {
            CXXFLAGS = "-I/sgoinfre/homebrew/include",
            LDFLAGS = "-L/sgoinfre/homebrew/lib",
          },
        })
      end,
      pyright = function()
        require("lspconfig").pyright.setup({
          cmd = { "/run/current-system/sw/bin/pyright" },
          filetypes = { "python" },
          single_file_support = false,
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly",
                useLibraryCodeForTypes = true,
              },
            },
          },
          before_init = function(_, config)
            config.settings.python.pythonPath = get_python_path(config.root_dir)
          end,
        })
      end,
      ruff = function()
        require("lspconfig").ruff.setup({
          cmd = { "/run/current-system/sw/bin/ruff", "server" },
        })
      end,
      bashls = function()
        require("lspconfig").bashls.setup({
          cmd = { "/run/current-system/sw/bin/bash-language-server", "start" },
        })
      end,
      -- Nix
      nil_ls = function()
        -- https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion
        -- https://github.com/hrsh7th/cmp-nvim-lsp/issues/42#issuecomment-1283825572
        local caps = vim.tbl_deep_extend(
          "force",
          vim.lsp.protocol.make_client_capabilities(),
          require("cmp_nvim_lsp").default_capabilities(),
          -- File watching is disabled by default for neovim.
          -- See: https://github.com/neovim/neovim/pull/22405
          { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } }
        )
        require("lspconfig").nil_ls.setup({
          cmd = { "/run/current-system/sw/bin/nil" },
          capabilities = caps,
          filetypes = { "nix" },
          root_dir = util.root_pattern("flake.nix", ".git"),
          settings = {
            ["nil"] = {
              testSetting = 42,
              formatting = {
                command = { "/run/current-system/sw/bin/nixfmt" },
              },
            },
          },
        })
      end,
      -- alejandra = function()
      --   require("lspconfig").alejandra.setup({
      --     cmd = { "/run/current-system/sw/bin/alejandra" },
      --   })
      -- end,
    })
  end,
}
