-- Core Neovim options

vim.g.mapleader = " "       -- Space as leader key
vim.g.maplocalleader = "\\" -- Backslash as local leader

local opt = vim.opt

-- Line numbers
opt.number = true           -- Show line numbers
opt.relativenumber = true   -- Relative line numbers

-- Tabs & indentation
opt.tabstop = 4             -- Tab = 4 spaces
opt.shiftwidth = 4          -- Indent = 4 spaces
opt.softtabstop = 4
opt.expandtab = true        -- Use spaces, not tabs
opt.smartindent = true

-- Search
opt.ignorecase = true       -- Case-insensitive search...
opt.smartcase = true        -- ...unless uppercase is used
opt.hlsearch = true         -- Highlight search results
opt.incsearch = true        -- Incremental search

-- Appearance
opt.termguicolors = true    -- True color support
opt.signcolumn = "yes"      -- Always show sign column
opt.cursorline = true       -- Highlight current line
opt.scrolloff = 8           -- Keep 8 lines above/below cursor
opt.sidescrolloff = 8
opt.wrap = true             -- Wrap long lines
opt.linebreak = true        -- Break at word boundaries

-- Splits
opt.splitright = true       -- Vertical splits to the right
opt.splitbelow = true       -- Horizontal splits below

-- Files
opt.swapfile = false
opt.backup = false
opt.undofile = true         -- Persistent undo

-- Misc
opt.updatetime = 250        -- Faster CursorHold
opt.timeoutlen = 300        -- Faster key sequence completion
opt.clipboard = "unnamedplus" -- System clipboard
opt.mouse = "a"             -- Mouse support
opt.showmode = false        -- Statusline shows mode instead
opt.completeopt = "menu,menuone,noselect"
