-- Colorscheme: tokyonight (popular, well-maintained, many variants)
return {
  "folke/tokyonight.nvim",
  lazy = false,    -- load immediately (before other plugins)
  priority = 1000, -- load before everything else
  opts = {
    style = "night", -- "storm", "moon", "night", or "day"
  },
  config = function(_, opts)
    require("tokyonight").setup(opts)
    vim.cmd.colorscheme("tokyonight")
  end,
}
