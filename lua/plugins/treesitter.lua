-- Treesitter: syntax highlighting, indentation, text objects
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master", -- REQUIRED: "main" branch needs Nvim 0.12+, "master" is for 0.11
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        -- Core
        "c", "lua", "vim", "vimdoc", "query",
        -- Your languages
        "python",
        "javascript", "typescript", "tsx",
        "go", "gomod", "gosum",
        -- Web
        "html", "css", "json", "jsonc",
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
      },
      sync_install = false,  -- install parsers asynchronously
      auto_install = true,   -- auto-install when entering a buffer with missing parser
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    })
  end,
}
-- To add a new language: just add its name to ensure_installed above
-- Full list of available parsers: https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
-- Or run :TSInstall <language> interactively
