# Neovim Usage Details

> Detailed reference for day-to-day Neovim usage, plugin-specific features, and
> troubleshooting. Intended for Claude Code sessions where the user asks detailed
> questions about their setup, wants usage advice, or needs help with changes.
>
> **Quick reference**: see `GUIDE.md` instead.

---

## Table of Contents

- [Neovim vs Vim: What's Different](#neovim-vs-vim-whats-different)
- [Plugin System (lazy.nvim)](#plugin-system-lazynvim)
- [Treesitter: Syntax Highlighting](#treesitter-syntax-highlighting)
- [LSP: Language Intelligence](#lsp-language-intelligence)
- [Completion (nvim-cmp)](#completion-nvim-cmp)
- [Telescope: Fuzzy Finding](#telescope-fuzzy-finding)
- [Editor Plugins](#editor-plugins)
- [Common Workflows](#common-workflows)
- [Vim Concepts Reference](#vim-concepts-reference)
- [Troubleshooting](#troubleshooting)
- [Upgrading to Neovim 0.12+](#upgrading-to-neovim-012)
- [Official Documentation Links](#official-documentation-links)

---

## Neovim vs Vim: What's Different

If you're coming from classic Vim:

| Feature | Vim | Neovim |
|---------|-----|--------|
| Config file | `~/.vimrc` (Vimscript) | `~/.config/nvim/init.lua` (Lua) |
| Plugin API | Vimscript only | Lua (fast, full language) |
| LSP support | Via plugin (coc.nvim) | Built-in (`vim.lsp`) |
| Treesitter | Not available | Built-in |
| Async jobs | Limited | Full async via `vim.uv` |
| Terminal | Basic `:terminal` | Better integrated terminal |

**Everything from Vim still works.** All your muscle memory (motions, text objects,
`:commands`, registers, macros) carries over. Neovim is a superset.

### Lua vs Vimscript

This config uses Lua exclusively. Quick Rosetta stone:

```
Vimscript                          Lua equivalent
-----------                        --------------
set number                         vim.opt.number = true
let g:mapleader = " "              vim.g.mapleader = " "
nnoremap <leader>w :w<CR>          vim.keymap.set("n", "<leader>w", "<cmd>w<CR>")
autocmd BufWritePre * ...          vim.api.nvim_create_autocmd("BufWritePre", {...})
```

You can still run any Vimscript command via `vim.cmd("...")`.

---

## Plugin System (lazy.nvim)

### How it works
- On startup, `lua/config/lazy.lua` bootstraps lazy.nvim (clones it if missing)
- `{ import = "plugins" }` tells it to load every `.lua` file in `lua/plugins/`
- Each file returns a plugin spec (or list of specs)
- Plugins are installed to `~/.local/share/nvim/lazy/`

### Key commands
| Command | What it does |
|---------|-------------|
| `:Lazy` | Dashboard — see all plugins, status, keybindings |
| `:Lazy sync` | Install missing + update all + clean removed |
| `:Lazy update` | Update plugins to latest |
| `:Lazy restore` | Restore plugins to versions in `lazy-lock.json` |
| `:Lazy clean` | Remove plugins no longer in config |
| `:Lazy profile` | Show startup performance profile |
| `:Lazy health` | Health check |

### Lazy loading
Plugins can be loaded on-demand for faster startup:
- `event = "InsertEnter"` — load when entering insert mode
- `event = "VeryLazy"` — load after UI, not blocking startup
- `event = { "BufReadPost", "BufNewFile" }` — load when opening a file
- `cmd = "Telescope"` — load when the command is first run
- `keys = { "<leader>ff" }` — load when the key is pressed
- `ft = "python"` — load for specific filetypes
- `lazy = false` — load immediately (use for colorschemes)

### Plugin spec anatomy
```lua
return {
  "github-user/repo-name",          -- required: GitHub repo
  branch = "main",                  -- optional: specific branch
  version = "v2.*",                 -- optional: version constraint
  dependencies = { "other/plugin" },-- optional: auto-install deps
  event = "VeryLazy",               -- optional: when to load
  opts = { ... },                   -- optional: passed to setup()
  config = function(_, opts)        -- optional: custom setup logic
    require("plugin").setup(opts)
  end,
  build = ":TSUpdate",              -- optional: run after install/update
}
```

### lazy-lock.json
This lockfile pins exact commit hashes for every plugin. Committed to git for
reproducibility. When you `:Lazy update`, the lockfile updates. Commit it to
record the change. `:Lazy restore` reverts to the lockfile versions.

---

## Treesitter: Syntax Highlighting

Treesitter parses code into a concrete syntax tree, enabling:
- **Accurate highlighting** (understands language grammar, not just regex patterns)
- **Smart indentation** (`indent.enable = true`)
- **Incremental selection** (`Ctrl+Space` to expand selection by syntax node, `Backspace` to shrink)

### Commands
| Command | What it does |
|---------|-------------|
| `:TSInstall <lang>` | Install a parser |
| `:TSUpdate` | Update all parsers |
| `:TSInstallInfo` | Show installed/available parsers |
| `:TSModuleInfo` | Show which modules are enabled per language |
| `:InspectTree` | Show the syntax tree for current buffer (great for debugging) |
| `:Inspect` | Show highlight groups under cursor |

### Adding a language
Add its name to `ensure_installed` in `lua/plugins/treesitter.lua`. With
`auto_install = true`, just opening a file of a known type will also trigger install.

Parser names are usually lowercase language names: `python`, `javascript`, `go`, `rust`,
`ruby`, `java`, `c_sharp`, `elixir`, `haskell`, etc.

### Incremental selection
In normal mode, press `Ctrl+Space` to start selecting. Press again to expand to the
next syntax node (e.g., word -> expression -> statement -> function -> class).
Press `Backspace` to shrink back. Very useful for selecting logical code blocks.

---

## LSP: Language Intelligence

LSP (Language Server Protocol) provides IDE features by communicating with
language-specific servers.

### What LSP gives you
- **Diagnostics** — errors/warnings shown inline and in the sign column
- **Go to definition** (`gd`) — jump to where a symbol is defined
- **Find references** (`gr`) — find all usages of a symbol
- **Hover docs** (`K`) — show documentation popup
- **Rename** (`Space rn`) — rename a symbol across all files
- **Code actions** (`Space ca`) — quick fixes, refactors, imports
- **Completions** — fed into nvim-cmp automatically

### How the LSP stack works
```
Mason installs servers  →  mason-lspconfig auto-enables them  →
nvim-lspconfig provides default configs  →  Neovim's built-in LSP client connects
```

You rarely interact with this directly — just add server names to `ensure_installed`.

### Commands
| Command | What it does |
|---------|-------------|
| `:Mason` | Open Mason UI — install/update/remove servers |
| `:LspInfo` | Show active LSP clients for current buffer |
| `:LspLog` | Show LSP client logs (for debugging) |
| `:LspRestart` | Restart LSP clients |

### Installed servers

| Server | Language | What it provides |
|--------|----------|-----------------|
| pyright | Python | Types, completions, diagnostics, go-to-def. Fast. |
| ts_ls | JS/TS | Full TypeScript intelligence |
| gopls | Go | Official Go language server |
| lua_ls | Lua | Lua intelligence, configured for Neovim's API |

### Customizing a server
Add a `vim.lsp.config()` call in `lua/plugins/lsp.lua`:
```lua
vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "strict",  -- "off", "basic", "standard", "strict"
      },
    },
  },
})
```

### Diagnostic display
- **Sign column**: icons appear next to lines with issues
- `[d` / `]d` — jump to previous/next diagnostic
- `Space e` — show full diagnostic message in a floating window
- `Space fd` — list all diagnostics in Telescope

---

## Completion (nvim-cmp)

nvim-cmp aggregates completions from multiple sources and presents them in a
popup menu.

### Sources (in priority order)
1. **nvim_lsp** — completions from the language server
2. **luasnip** — snippet expansions
3. **buffer** — words from the current buffer (fallback)
4. **path** — file system paths

### Using completion
- Completion triggers automatically as you type
- `Ctrl+Space` — manually trigger completion
- `Tab` / `Shift+Tab` — navigate items
- `Enter` — confirm selection
- `Ctrl+e` — dismiss menu
- `Ctrl+b` / `Ctrl+f` — scroll documentation preview

### Snippets (LuaSnip + friendly-snippets)
The config includes VS Code-compatible snippets for many languages. When a snippet
appears in the completion menu (usually marked with a snippet icon), confirming it
inserts the snippet template. Use `Tab` to jump between placeholders.

Examples (Python):
- Type `def` → expands to function definition with placeholders
- Type `class` → expands to class template
- Type `ifmain` → expands to `if __name__ == "__main__":` block

### Command-line completion
nvim-cmp also completes in the command line:
- `:` commands get command + path completion
- `/` and `?` search get buffer word completion

---

## Telescope: Fuzzy Finding

Telescope is a fuzzy finder for everything. It uses ripgrep for text search
and fd for file finding.

### Key bindings
| Key | What it searches |
|-----|-----------------|
| `Space ff` | Files (respects .gitignore) |
| `Space fg` | Text across all files (live grep) |
| `Space fb` | Open buffers |
| `Space fr` | Recently opened files |
| `Space fh` | Help tags (search Neovim docs) |
| `Space /` | Text in current buffer |
| `Space fs` | LSP document symbols (functions, classes, etc.) |
| `Space fw` | LSP workspace symbols |
| `Space fd` | Diagnostics |

### Inside Telescope
| Key | Action |
|-----|--------|
| `Ctrl+j / Ctrl+k` | Move up/down in results |
| `Enter` | Open selected file |
| `Ctrl+x` | Open in horizontal split |
| `Ctrl+v` | Open in vertical split |
| `Ctrl+t` | Open in new tab |
| `Ctrl+u / Ctrl+d` | Scroll preview up/down |
| `Esc` | Close (in normal mode) |
| `Ctrl+c` | Close (in insert mode) |

### Tips
- In `find_files`, type path fragments separated by spaces: `src comp button`
  matches `src/components/Button.tsx`
- In `live_grep`, the search is regex-aware (it's ripgrep)
- `Space fh` is great for learning Neovim — search for any topic

---

## Editor Plugins

### gitsigns.nvim
Shows git diff markers in the sign column (left margin).
- `]h` / `[h` — jump to next/previous hunk
- `Space gp` — preview the hunk (see what changed)
- `Space gb` — show git blame for the current line

### which-key.nvim
Press any prefix key (like `Space`) and pause — a popup shows all available
continuations. Great for discovering keybindings.
- `Space ?` — show all buffer-local keymaps

### nvim-autopairs
Auto-closes brackets, quotes, etc. Type `(` and `)` appears. Works with
nvim-cmp (auto-adds closing pair after confirming a function completion).

### Comment.nvim
- `gcc` — toggle comment on current line
- `gc` (visual mode) — toggle comment on selection
- `gcap` — comment a paragraph

### indent-blankline.nvim
Shows indent guides (vertical lines) and highlights the current scope.

### lualine.nvim
Statusline showing: mode, git branch, diff stats, diagnostics, filename,
encoding, filetype, cursor position. Themed to match tokyonight.

---

## Common Workflows

### "I opened a Python file, what can I do?"
1. Syntax highlighting is automatic (Treesitter)
2. LSP starts automatically (pyright) — wait a moment for it to index
3. Start typing → completions appear
4. `K` on any symbol → hover docs
5. `gd` → jump to definition
6. `gr` → find all references
7. `Space rn` → rename a variable everywhere
8. `Space ca` → quick fixes (add import, etc.)
9. `Space e` → see full error message
10. `Space fg` → search for text across the project

### "I want to navigate a new codebase"
1. `Space ff` → find files by name
2. `Space fg` → search for specific text/function names
3. `Space fs` → browse symbols in current file
4. `gd` → follow definitions
5. `gr` → see where things are used
6. `Ctrl+o` → jump back (Neovim maintains a jump list)
7. `Ctrl+i` → jump forward

### "I want to see what changed in git"
1. Gutter signs show added/modified/deleted lines
2. `]h` / `[h` → navigate between changes
3. `Space gp` → preview a change
4. `Space gb` → who changed this line?

---

## Vim Concepts Reference

Quick refresher on core Vim concepts that are useful with this config.

### Registers
- `"` — default register (last yank/delete)
- `"+` — system clipboard (mapped via `clipboard = "unnamedplus"`)
- `"0` — last yank (not affected by deletes)
- `"_` — black hole register (delete without saving)
- `Space p` — paste without overwriting register (visual mode)

### Marks
- `ma` — set mark 'a' at cursor
- `` `a `` — jump to mark 'a'
- `` `. `` — jump to last change
- `` `" `` — jump to last position when file was closed (this config restores this automatically)

### Jump list
- `Ctrl+o` — jump back
- `Ctrl+i` — jump forward
- `:jumps` — see the list

### Macros
- `qa` — start recording macro into register 'a'
- `q` — stop recording
- `@a` — replay macro 'a'
- `@@` — replay last macro

### Text objects (most useful ones)
- `iw` / `aw` — inner/around word
- `i"` / `a"` — inner/around quotes
- `i(` / `a(` — inner/around parentheses (also `ib` / `ab`)
- `i{` / `a{` — inner/around braces (also `iB` / `aB`)
- `if` / `af` — inner/around function (with Treesitter text objects, if added)
- Usage: `ci"` = change inside quotes, `da(` = delete around parens, `vi{` = select inside braces

### Splits
- `:vs` / `:sp` — vertical/horizontal split
- `Ctrl+h/j/k/l` — navigate between splits (this config)
- `Ctrl+arrows` — resize splits (this config)

---

## Troubleshooting

### "No LSP features / completions not working"
1. Check `:LspInfo` — is a server attached?
2. Check `:Mason` — is the server installed?
3. Check `:LspLog` for errors
4. Some servers need the project root to contain certain files (e.g., `pyproject.toml` for pyright)

### "Treesitter highlighting looks wrong"
1. `:TSInstallInfo` — is the parser installed?
2. `:TSUpdate` — update parsers
3. `:InspectTree` — examine the syntax tree

### "Plugin not loading"
1. `:Lazy` — check status
2. Check if it's lazy-loaded (might need to trigger its load event)
3. `:Lazy health` — run health checks

### "Startup is slow"
1. `:Lazy profile` — see what's taking time
2. Add lazy-loading triggers to slow plugins

### "Something broke after update"
1. `:Lazy restore` — revert to lockfile versions
2. Check plugin changelogs in `:Lazy` dashboard

---

## Upgrading to Neovim 0.12+

When you upgrade Neovim to 0.12+, you must migrate the Treesitter config:

1. In `lua/plugins/treesitter.lua`, change `branch = "master"` to `branch = "main"`
2. The setup API changes:
   - Old (0.11): `require("nvim-treesitter.configs").setup({ ensure_installed = {...}, highlight = { enable = true } })`
   - New (0.12): `require("nvim-treesitter").setup({})` + install parsers via `require("nvim-treesitter").install({...})`
   - Highlighting: enabled via `vim.treesitter.start()` or auto-enabled

Check the nvim-treesitter README on the `main` branch for the current API when upgrading.

---

## Official Documentation Links

- **Neovim docs**: `:help` in Neovim, or https://neovim.io/doc/
- **Neovim Lua guide**: `:help lua-guide`
- **lazy.nvim**: https://lazy.folke.io/
- **nvim-treesitter**: https://github.com/nvim-treesitter/nvim-treesitter
- **nvim-lspconfig**: https://github.com/neovim/nvim-lspconfig
- **nvim-lspconfig server list**: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
- **mason.nvim**: https://github.com/mason-org/mason.nvim
- **nvim-cmp**: https://github.com/hrsh7th/nvim-cmp
- **telescope.nvim**: https://github.com/nvim-telescope/telescope.nvim
- **tokyonight theme**: https://github.com/folke/tokyonight.nvim
- **LuaSnip**: https://github.com/L3MON4D3/LuaSnip
- **friendly-snippets**: https://github.com/rafamadriz/friendly-snippets
