-- Autocompletion via nvim-cmp
return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter", -- lazy-load: only when entering insert mode
  dependencies = {
    "hrsh7th/cmp-nvim-lsp", -- LSP completions
    "hrsh7th/cmp-buffer",   -- Buffer word completions
    "hrsh7th/cmp-path",     -- File path completions
    "hrsh7th/cmp-cmdline",  -- Command-line completions
    -- Snippet engine + snippet collection
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp",
      dependencies = { "rafamadriz/friendly-snippets" },
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),       -- trigger completion
        ["<C-e>"] = cmp.mapping.abort(),               -- close completion
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- confirm selection
        -- Tab: navigate completion OR jump in snippet
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
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
      sources = cmp.config.sources({
        { name = "nvim_lsp" }, -- LSP suggestions (highest priority)
        { name = "luasnip" },  -- Snippets
      }, {
        { name = "buffer" },   -- Words from current buffer
        { name = "path" },     -- File paths
      }),
    })

    -- Command-line completions
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = { { name = "buffer" } },
    })
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources(
        { { name = "path" } },
        { { name = "cmdline" } }
      ),
    })
  end,
}
