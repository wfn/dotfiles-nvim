# CLAUDE.md — Neovim Configuration

> Personal Neovim configuration. Lua-based, using lazy.nvim plugin manager.
> Targets **Neovim 0.12+** on macOS.

---

## Documentation Index

| Task | Doc | Notes |
|------|-----|-------|
| **Understanding the setup** | This file | Architecture, directory structure, key decisions |
| **Keybindings, usage, how-to** | `GUIDE.md` | Quick reference for daily use |
| **Detailed usage / plugin questions** | `USAGE_DETAILS.md` | Deep dives, nvim concepts, plugin-specific help, troubleshooting |
| **Fresh machine setup** | `SETUP.md` | Prerequisites, install steps, first-launch checklist |
| **Testing / regression checks** | `TESTING.md` | Headless test suite, run after upgrades or config changes |
| **Adding a new language** | `GUIDE.md` § "Add Syntax Highlighting" + "Add IDE Features" | Treesitter parser + LSP server |
| **Adding a new plugin** | `GUIDE.md` § "Add a New Plugin" | Create file in `lua/plugins/` |
| **Changing keybindings** | `GUIDE.md` § "Add Custom Keybindings" | Edit `lua/config/keymaps.lua` |
| **Changing settings** | `GUIDE.md` § "Change Core Settings" | Edit `lua/config/options.lua` |

---

## Project Overview

This is a single-user Neovim config repo. The config is written entirely in **Lua**
(Neovim's native config language, replacing Vimscript).

**Key components:**
- **lazy.nvim** — plugin manager (auto-discovers `lua/plugins/*.lua`)
- **nvim-treesitter** — syntax highlighting via tree-sitter parsers (30+ languages)
- **nvim-lspconfig + mason.nvim** — LSP integration (IDE features: go-to-def, completions, diagnostics)
- **nvim-cmp** — autocompletion engine (LSP + snippets + buffer + paths)
- **telescope.nvim** — fuzzy finder (files, grep, symbols, buffers)

---

## Directory Structure

```
~/.config/nvim/
├── init.lua                   # Entry point — loads config/, then plugins
├── lazy-lock.json             # Plugin version lockfile (committed)
├── .gitignore
├── CLAUDE.md                  # This file
├── GUIDE.md                   # Quick reference guide
├── USAGE_DETAILS.md           # Detailed usage / troubleshooting
├── SETUP.md                   # Fresh machine setup instructions
├── TESTING.md                 # Regression test suite
├── lua/
│   ├── config/                # Core settings (loaded before plugins)
│   │   ├── lazy.lua           # lazy.nvim bootstrap + setup
│   │   ├── options.lua        # Vim options (tabs, numbers, search, etc.)
│   │   ├── keymaps.lua        # Keybindings (general + LSP-on-attach)
│   │   └── autocmds.lua       # Autocommands (yank highlight, trim whitespace, etc.)
│   └── plugins/               # One file per plugin/group — lazy.nvim auto-loads all
│       ├── colorscheme.lua    # tokyonight theme
│       ├── treesitter.lua     # Syntax highlighting (30+ languages)
│       ├── lsp.lua            # LSP servers via Mason (pyright, ts_ls, gopls, lua_ls)
│       ├── completion.lua     # nvim-cmp + LuaSnip + friendly-snippets
│       ├── telescope.lua      # Fuzzy finder
│       ├── ui.lua             # Statusline (lualine), icons, indent guides
│       └── editor.lua         # gitsigns, which-key, autopairs, Comment.nvim
```

---

## Key Architecture Decisions

1. **Neovim, not Vim.** Treesitter and native LSP are Neovim features. Classic Vim
   cannot use this config. Run `nvim` (or alias `vim=nvim`).

2. **lazy.nvim auto-discovery.** Plugin specs live in `lua/plugins/*.lua`. Each file
   returns a table (or list of tables). No central plugin list to maintain — just add
   a file.

3. **Treesitter `main` branch.** Uses the `main` branch of nvim-treesitter, which
   targets Nvim 0.12+. The plugin setup uses `require("nvim-treesitter").setup()` +
   `install()` + FileType autocmds for highlight/indent. The tree-sitter CLI (installed
   via npm) is a required dependency.

4. **New LSP API.** Uses `vim.lsp.config()` + `vim.lsp.enable()` (Nvim 0.11+), not the
   deprecated `require('lspconfig').server.setup{}` pattern. Mason-lspconfig's
   `automatic_enable = true` handles enabling. LSP status is checked via
   `:checkhealth vim.lsp` (not the old `:LspInfo`), and servers are restarted with
   `:lsp restart` (not the old `:LspRestart`).

5. **LuaSnip + friendly-snippets** for completion snippets. Provides VS Code-style
   snippet libraries for many languages out of the box.

6. **Leader key is Space.** All custom keybindings use `<leader>` prefix. Press Space
   and pause to see which-key popup.

---

## How to Make Changes

### Add a plugin
Create `lua/plugins/<name>.lua` returning a spec table. See `GUIDE.md`.

### Add a language
1. Add treesitter parser name to the `install()` call in `lua/plugins/treesitter.lua`
2. Add LSP server name to `ensure_installed` in `lua/plugins/lsp.lua`
3. Restart Neovim

### Change keybindings
Edit `lua/config/keymaps.lua`. LSP-specific keymaps are in the `LspAttach` autocmd
in that same file.

### Change options
Edit `lua/config/options.lua`.

### Customize a specific LSP server
Add a `vim.lsp.config("server_name", { ... })` call in `lua/plugins/lsp.lua`.

---

## Dev Notes

- **lazy-lock.json** is committed for reproducibility. Run `:Lazy sync` to update.
- Plugins are installed to `~/.local/share/nvim/lazy/` (not in this repo).
- Treesitter parsers are compiled to `~/.local/share/nvim/lazy/nvim-treesitter/parser/`.
- Mason installs LSP servers to `~/.local/share/nvim/mason/`.
- **tree-sitter CLI** is required for compiling parsers. Install via `npm install -g tree-sitter-cli`.
- On a fresh machine: clone this repo to `~/.config/nvim`, ensure the tree-sitter CLI
  is installed, open `nvim` — everything auto-installs on first launch.

---

## Git Setup

This repo uses a personal (non-work) GitHub identity:
- **SSH host alias:** `gitpersonal` (see `~/.ssh/config`)
- **Remote URL format:** `gitpersonal:wfn/<repo>.git`
- **Local git config:** name and email set per-repo (not global)
