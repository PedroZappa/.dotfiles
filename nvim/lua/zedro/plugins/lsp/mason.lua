return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  lazy = false,
  config = function()
    local lsp_zero = require('lsp-zero')
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
        "prettier", -- prettier formatter
        "stylua",   -- lua formatter
        -- "eslint_d", -- js linter
        -- "black",    -- python formatter
        -- "isort",    -- python import sorter
        -- "debugpy",  -- python debugger
      },
    })
    vim.api.nvim_command('MasonToolsInstall')

    mason_lspconfig.setup({
      ensure_installed = {
        "clangd",
        "lua_ls",
        -- "jsonls",                    -- json
        -- "html",                      -- html
        -- "pyright",                   -- python
      },
      automatic_installation = true, -- not the same as ensure_installed
      handlers = {
        -- this first function is the "default handler"
        -- it applies to every language server without a "custom handler"
        function(server_name)
          require('lspconfig')[server_name].setup({})
        end,
        lsp_zero.default_setup,
        lua_ls = function()
          require('lspconfig').lua_ls.setup({
            on_init = function(client)
              local uv = vim.uv or vim.loop
              -- local path = client.workspace_folders[1].name

              -- lsp_zero.nvim_lua_settings(client, {})
              -- Don't do anything if there is a project local config
              -- if uv.fs_stat(path .. '/.luarc.json')
              --     or uv.fs_stat(path .. '/.luarc.jsonc')
              -- then
              --   return
              -- end
              -- Apply neovim specific settings
              local lua_opts = lsp_zero.nvim_lua_ls()

              client.config.settings.Lua = vim.tbl_deep_extend(
                'force',
                client.config.settings.Lua,
                lua_opts.settings.Lua
              )
            end,
            settings = {
              Lua = {
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
            cmd = { "/run/current-system/sw/bin/clangd",
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
                "-I/usr/local/lib",                  -- System-wide include
              }
            },
            filetypes = { "c", "h", "hpp", "cpp", "objc", "objcpp" },
            cmd_env = {
              CXXFLAGS = "-I/sgoinfre/homebrew/include",
              LDFLAGS = "-L/sgoinfre/homebrew/lib"
            },
          })
        end,
        pyright = function()
          require("lspconfig").pyright.setup({
            cmd = { "pyright-langserver", "--stdio" },
            filetypes = { "python" },
            single_file_support = false,
            settings = {
              python = {
                analysis = {
                  autoSearchPaths = true,
                  diagnosticMode = "openFilesOnly",
                  useLibraryCodeForTypes = true
                }
              }
            },
            before_init = function(_, config)
              config.settings.python.pythonPath = get_python_path(config.root_dir)
            end,
          })
        end,
      },
    })
  end,
}
