return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "neovim/nvim-lspconfig",        -- LSP
    'hrsh7th/cmp-nvim-lsp',
    "hrsh7th/cmp-buffer",           -- source for text in buffer
    "hrsh7th/cmp-path",             -- source for file system paths
    "hrsh7th/cmp-cmdline",          -- source for cmdline
    -- 'hrsh7th/cmp-omni',				-- source for omnifunc
    "L3MON4D3/LuaSnip",             -- snippet engine
    "saadparwaiz1/cmp_luasnip",     -- for autocompletion
    "rafamadriz/friendly-snippets", -- useful snippets
    "onsails/lspkind.nvim",         -- vs-code like pictograms
    -- { "quangnguyen30192/cmp-nvim-tags", ft = "markdown" },	-- nvim-tags
  },
  config = function()
    -- local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")
    -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
    require("luasnip.loaders.from_vscode").lazy_load()
    -- Nerdfont Icons
    local kind_icons = {
      Text = "",
      Method = "m",
      Function = "",
      Constructor = "",
      Field = "",
      Variable = "",
      Class = "",
      Interface = "",
      Module = "",
      Property = "",
      Unit = "",
      Value = "",
      Enum = "",
      Keyword = "",
      Snippet = "",
      Color = "",
      File = "",
      Reference = "",
      Folder = "",
      EnumMember = "",
      Constant = "",
      Struct = "",
      Event = "",
      Operator = "",
      TypeParameter = "",
    }

    cmp.setup({
      snippet = { -- configure how nvim-cmp interacts with snippet engine
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-2),
        ["<C-f>"] = cmp.mapping.scroll_docs(2),
        ["<C-Space>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.abort()
          else
            cmp.complete()
          end
        end, { "i", "s" }),
        ["<C-x>"] = cmp.mapping.abort(), -- close completion window
        ["<C-y>"] = cmp.mapping.confirm({
          behaviour = cmp.ConfirmBehavior.Replace,
          select = false,
        }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() and cmp.get_selected_entry() ~= nil then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({ -- sources for autocompletion
        { name = "nvim_lsp" },
        { name = "nvim_lua" },
        { name = "lsp_kind" },
        { name = "luasnip" }, -- snippets
        { name = "buffer" },  -- text within current buffer
        -- { name = "path" },    -- file system paths
        { name = "codeium" }, -- codeium
        -- { name = "cmdline" }, -- cmdline
        {
          name = "tags",
          option = {
            -- this is the default options, change them if you want.
            -- Delayed time after user input, in milliseconds.
            complete_defer = 100,
            -- Max items when searching `taglist`.
            max_items = 10,
            -- Use exact word match when searching `taglist`, for better searching
            -- performance.
            exact_match = false,
            -- Prioritize searching result for current buffer.
            current_buffer_only = false,
          },
        },
      }),
      confirm_opts = {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
      },
      experimental = {
        ghost_text = true,
        native_menu = false,
      },
      completion = {
        completeopt = "menu,menuone,preview,noselect",
        -- autocomplete = false,
      },
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          -- Use your already defined kind_icons table
          local kind = vim_item.kind
          vim_item.kind = string.format("%s %s", kind_icons[kind] or "", kind)

          -- Set menu based on source
          vim_item.menu = ({
            nvim_lsp = "[LSP]",
            nvim_lua = "[Lua]",
            luasnip = "[Snippet]",
            buffer = "[Buffer]",
            path = "[Path]",
            codeium = "[Codeium]",
            cmdline = "[Cmd]",
            tags = "[Tags]",
          })[entry.source.name] or ""

          return vim_item
        end,
      },
    })
    -- `/` cmdline setup.
    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })
    -- `:` cmdline setup.
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        { name = "cmdline" },
      }),
    })
  end,
}
