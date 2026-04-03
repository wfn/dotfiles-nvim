-- LSP: Language Server Protocol (IDE features: go-to-definition, diagnostics, etc.)
-- Mason: auto-installs LSP servers so you don't have to install them manually
return {
  -- Mason: package manager for LSP servers, formatters, linters
  {
    "mason-org/mason.nvim",
    opts = {
      ui = {
        border = "rounded",
      },
    },
  },

  -- Bridge: tells Mason which LSP servers to install, auto-enables them
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "pyright",      -- Python
        "ts_ls",        -- TypeScript / JavaScript
        "gopls",        -- Go
        "lua_ls",       -- Lua (for editing nvim config)
      },
      automatic_enable = true, -- auto-calls vim.lsp.enable() for installed servers
    },
  },

  -- LSP configs (provides default configurations for each server)
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Configure all LSP servers to use nvim-cmp's capabilities
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      -- Lua LSP: make it aware of Neovim runtime (for editing nvim config)
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              library = { vim.env.VIMRUNTIME },
            },
          },
        },
      })
    end,
  },
}
-- To add a new language server:
-- 1. Add its name to ensure_installed above (e.g., "rust_analyzer" for Rust)
-- 2. Mason will auto-install it; mason-lspconfig will auto-enable it
-- 3. Find server names at: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
-- 4. Or run :Mason to browse and install interactively
