return {
  "jose-elias-alvarez/null-ls.nvim",
  config = function()
    local null_ls = require("null-ls")
    require("null-ls").setup({
      sources = {
        null_ls.builtins.code_actions.shellcheck,
        null_ls.builtins.diagnostics.ansiblelint,
        null_ls.builtins.diagnostics.golangci_lint.with({
          args = {
            "run",
            "--fix=false",
            "--out-format=json",
            "$DIRNAME",
            "--path-prefix",
            "$ROOT",
          },
        }),
        null_ls.builtins.diagnostics.alex,
        null_ls.builtins.diagnostics.jsonlint,
        null_ls.builtins.diagnostics.markdownlint.with({
          args = { "-c", "~/.markdownlint.yaml", "--stdin" },
        }),
        null_ls.builtins.diagnostics.shellcheck,
        null_ls.builtins.diagnostics.write_good,
        null_ls.builtins.diagnostics.yamllint,
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.cbfmt.with({
          extra_args = { "--config", "/home/neovim/.cbfmt.toml" }
        }),
        null_ls.builtins.formatting.fixjson,
        null_ls.builtins.formatting.prettier.with({
          disabled_filetypes = { "go", "yaml" },
          extra_args = { "--prose-wrap", "always" }
        }),
        null_ls.builtins.formatting.shfmt.with({
          args = { "-i", "2", "-filename", "$FILENAME" }
        }),
        null_ls.builtins.formatting.trim_whitespace.with({
          disabled_filetypes = { "go" },
        }),
      },
    })
  end,
}
