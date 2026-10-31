return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- Merges over lspconfig's defaults for pylsp (cmd, filetypes, root_markers).
      -- pylsp is a plugin host and its defaults are noisy, so trim them.
      vim.lsp.config("pylsp", {
        settings = {
          pylsp = {
            plugins = {
              pyflakes = { enabled = true },  -- real errors
              pycodestyle = { enabled = false }, -- 79-column noise
              pydocstyle = { enabled = false },
              mccabe = { enabled = false },
              pylint = { enabled = false },
              autopep8 = { enabled = false },
              yapf = { enabled = false },
              jedi_completion = { fuzzy = true },
              rope_autoimport = { enabled = true },
            },
          },
        },
      })

      vim.lsp.enable("pylsp")
    end,
  },
}
