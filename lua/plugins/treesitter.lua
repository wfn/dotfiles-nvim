-- Treesitter: parser management, syntax highlighting, indentation
-- Main branch requires Neovim 0.12+ and tree-sitter CLI on PATH

local parsers = {
  -- Core
  "c", "lua", "vim", "vimdoc", "query",
  -- Your languages
  "python",
  "javascript", "typescript", "tsx",
  "go", "gomod", "gosum",
  -- Web
  "html", "css", "json",
  -- Config / data
  "yaml", "toml", "ini",
  -- Shell / infra
  "bash", "dockerfile", "hcl",
  -- Docs
  "markdown", "markdown_inline",
  -- Other useful
  "rust", "sql", "graphql", "proto",
  "gitcommit", "gitignore", "diff",
  "regex",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup()

    -- Install parsers (replaces ensure_installed)
    vim.defer_fn(function()
      require("nvim-treesitter").install(parsers)
    end, 0)

    -- Enable treesitter highlighting for all filetypes with a parser
    -- (replaces highlight = { enable = true })
    -- pcall guards against filetypes with no parser (e.g. TelescopePrompt)
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter-highlight", { clear = true }),
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })

    -- Enable treesitter-based indentation
    -- (replaces indent = { enable = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter-indent", { clear = true }),
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        if lang and pcall(vim.treesitter.language.add, lang) then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
-- Incremental selection is now built into Neovim 0.12:
--   an = expand to parent node (visual mode)
--   in = shrink to child node (visual mode)
-- No plugin config needed.
--
-- To add a new language: add its parser name to the parsers list above
-- Full list: https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
-- Or run :TSInstall <language> interactively
