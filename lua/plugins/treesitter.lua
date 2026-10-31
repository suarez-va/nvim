return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- the rewrite; `master` is the locked legacy branch
    lazy = false,    -- upstream: "This plugin does not support lazy-loading."
    build = ":TSUpdate",
    config = function()
      local TS = require("nvim-treesitter")

      TS.setup({
        -- prepended to runtimepath, so these parsers/queries win over the
        -- 7 that Neovim bundles
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      local ensure = {
        -- core / config editing
        "lua", "vim", "vimdoc", "query", "bash",
        -- data & markup
        "json", "yaml", "toml", "markdown", "markdown_inline", "rst",
        -- day job
        "python", "c", "cpp", "fortran",
        -- build systems (CMakeLists.txt + *.cmake is ~13.6k files here)
        "cmake", "make",
        -- papers
        "latex", "bibtex",
        -- git
        "diff", "gitcommit",
      }

      -- only fetch what's missing, so startup isn't a no-op network call
      local installed = TS.get_installed("parsers")
      local missing = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end, ensure)
      if #missing > 0 then
        TS.install(missing)
      end

      -- On the `main` branch the plugin ships ONLY parsers + queries.
      -- Highlighting is a Neovim feature you turn on yourself.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
          -- `get_lang` falls back to returning the filetype itself, and `add`
          -- returns nil (it does NOT raise) when no parser exists -- so the only
          -- reliable gate is `add`'s RETURN VALUE. This is what filters out
          -- plugin UI buffers (snacks_notif_history, lazy, TelescopePrompt, ...).
          if not (lang and vim.treesitter.language.add(lang)) then
            return
          end
          -- A parser can exist while its highlights query fails to compile
          -- against the grammar revision nvim-treesitter pins. `fortran` is
          -- currently such a case ('Invalid node type ".and."'), and
          -- `start` would raise from inside highlighter.new(). Check first;
          -- affected filetypes fall back to Vim's regex syntax.
          if not pcall(vim.treesitter.query.get, lang, "highlights") then
            return
          end
          vim.treesitter.start(args.buf, lang)

          -- Treesitter indentation. Upstream marks this EXPERIMENTAL; if Python
          -- indenting misbehaves, delete this line to fall back to Neovim's.
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

          -- Treesitter folding, deliberately left off. To enable, uncomment
          -- both lines AND set `vim.opt.foldlevel = 99` in config/options.lua,
          -- otherwise every file opens fully collapsed.
          -- vim.wo[0][0].foldmethod = "expr"
          -- vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end,
      })
    end,
  },
}
