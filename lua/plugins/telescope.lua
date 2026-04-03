-- Telescope: fuzzy finder for files, text, symbols, and more
return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  cmd = "Telescope",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep (search text)" },
    { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Open buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
    { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
    { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
    { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Document symbols" },
    { "<leader>fw", "<cmd>Telescope lsp_workspace_symbols<CR>", desc = "Workspace symbols" },
    { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Search in buffer" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        file_ignore_patterns = { "node_modules", ".git/", "__pycache__", "*.pyc" },
      },
      extensions = {
        fzf = {},
      },
    })
    telescope.load_extension("fzf")
  end,
}
-- Requires: ripgrep (rg) for live_grep, fd (optional, faster file finding)
-- Both installed via: brew install ripgrep fd
