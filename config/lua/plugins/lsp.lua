return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "SmiteshP/nvim-navic" },
    { "ray-x/lsp_signature.nvim" },
  },
  config = function()
    local lspconfig = require("lspconfig")
    local navic = require("nvim-navic")
    local function default_on_attach(client, bufnr)
      navic.attach(client, bufnr)

      local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
      end

      -- Enable completion triggered by <c-x><c-o>
      buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
      require("lsp_signature").on_attach({
        bind = true, -- This is mandatory, otherwise border config won't get registered.
        fix_pos = true,
        toggle_key = "<F2>",
        hi_parameter = "Search",
        handler_opts = {
          border = "rounded",
        },
      }, bufnr)
    end

    lspconfig.ansiblels.setup({ on_attach = default_on_attach })
    lspconfig.bashls.setup({ on_attach = default_on_attach })
    lspconfig.clangd.setup({ on_attach = default_on_attach })
    lspconfig.dockerls.setup({ on_attach = default_on_attach })
    lspconfig.jsonls.setup({ on_attach = default_on_attach })
    lspconfig.marksman.setup({ on_attach = default_on_attach })
    lspconfig.pyright.setup({ on_attach = default_on_attach })
    lspconfig.solargraph.setup({ on_attach = default_on_attach })
    lspconfig.taplo.setup({ on_attach = default_on_attach })
    lspconfig.terraformls.setup({ on_attach = default_on_attach })
    lspconfig.yamlls.setup({
      on_attach = function(_, bufnr)
        if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].filetype == "helm" then
          vim.diagnostic.disable(bufnr)
          vim.defer_fn(function()
            vim.diagnostic.reset(nil, bufnr)
          end, 1000)
        end
      end
    })

    lspconfig.gopls.setup({
      on_attach = default_on_attach,
      settings = {
        gopls = {
          gofumpt = true,
        },
      },
    })

    local runtime_path = vim.split(package.path, ';')
    table.insert(runtime_path, 'lua/?.lua')
    table.insert(runtime_path, 'lua/?/init.lua')

    lspconfig.lua_ls.setup({
      on_attach = default_on_attach,
      settings = {
        Lua = {
          -- Disable telemetry
          telemetry = { enable = false },
          runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT',
            path = runtime_path,
          },
          diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = { 'vim' }
          },
          workspace = {
            library = {
              -- Make the server aware of Neovim runtime files
              vim.fn.expand('$VIMRUNTIME/lua'),
              vim.fn.stdpath('config') .. '/lua'
            }
          }
        },
      },
    })
  end,
}
