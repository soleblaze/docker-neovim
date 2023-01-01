return {
  "VonHeikemen/lsp-zero.nvim",
  dependencies = {
    -- LSP Support
    { "neovim/nvim-lspconfig" },

    -- Autocompletion
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "saadparwaiz1/cmp_luasnip" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-nvim-lua" },

    -- Snippets
    { "L3MON4D3/LuaSnip" },
    { "rafamadriz/friendly-snippets" },
  },
  config = function()
    local lsp = require('lsp-zero')

    lsp.set_preferences({
      suggest_lsp_servers = false,
      setup_servers_on_start = true,
      set_lsp_keymaps = false,
      configure_diagnostics = true,
      cmp_capabilities = true,
      manage_nvim_cmp = true,
      call_servers = 'global',
      sign_icons = {
        error = '✘',
        warn = '▲',
        hint = '⚑',
        info = ''
      }
    })

    local cmp = require('cmp')
    local cmp_autopairs = require('nvim-autopairs.completion.cmp')

    cmp.event:on(
      'confirm_done',
      cmp_autopairs.on_confirm_done()
    )

    local luasnip = require('luasnip')

    lsp.setup_nvim_cmp({
      mapping = cmp.mapping.preset.insert({
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-e>"] = cmp.mapping.close(),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif cmp and cmp.visible() then
            cmp.confirm()
          else
            fallback()
          end
        end, { "i", "s", }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s", }),
        ["<C-n>"] = cmp.mapping(function(fallback)
          if luasnip.jumpable(1) then
            luasnip.jump(1)
          elseif cmp and cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end, { "i", "s", }),
        ["<C-p>"] = cmp.mapping(function(fallback)
          if luasnip.jumpable(-1) then
            luasnip.jump(-1)
          elseif cmp and cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { "i", "s", }),
        ["<Down>"] = cmp.mapping(function(fallback)
          if cmp and cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end, { "i", "s", }),
        ["<Up>"] = cmp.mapping(function(fallback)
          if cmp and cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { "i", "s", }),
        ["<CR>"] = cmp.mapping(function()
          cmp.autopairs.on_confirm_done({ map_char = { tex = "" } })
        end, {}),
      })

    })

    lsp.configure('gopls', {
      settings = {
        gopls = {
          gofumpt = true,
        },
      },
    })
    lsp.configure('yamlls', {
      on_attach = function(_, bufnr)
        if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].filetype == "helm" then
          vim.diagnostic.disable(bufnr)
          vim.defer_fn(function()
            vim.diagnostic.reset(nil, bufnr)
          end, 1000)
        end
      end
    })
    lsp.nvim_workspace()

    lsp.setup()
  end,
}
