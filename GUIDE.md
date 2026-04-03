# Neovim Setup Guide

Your Neovim config lives at `~/.config/nvim/`. It uses **Lua** (not Vimscript), with
**lazy.nvim** as the plugin manager. Everything auto-installs on first launch.

> **Using `nvim` instead of `vim`**: This is a Neovim setup. Run `nvim` to use it.
> To make `vim` launch Neovim, add to your `~/.zshrc`:
> ```sh
> alias vim="nvim"
> ```

---

## Directory Structure

```
~/.config/nvim/
├── init.lua                   # Entry point — loads config modules, then plugins
├── lua/
│   ├── config/
│   │   ├── lazy.lua           # Plugin manager bootstrap (don't touch unless upgrading)
│   │   ├── options.lua        # Core settings (line numbers, tabs, search, etc.)
│   │   ├── keymaps.lua        # All custom keybindings + LSP keymaps
│   │   └── autocmds.lua       # Auto-actions (highlight yank, trim whitespace, etc.)
│   └── plugins/               # Each file = one plugin or group of related plugins
│       ├── colorscheme.lua    # Theme (tokyonight)
│       ├── treesitter.lua     # Syntax highlighting for 30+ languages
│       ├── lsp.lua            # Language servers (IDE features)
│       ├── completion.lua     # Autocompletion (nvim-cmp + snippets)
│       ├── telescope.lua      # Fuzzy finder (files, grep, symbols)
│       ├── ui.lua             # Statusline, icons, indent guides
│       └── editor.lua         # Git signs, which-key, auto-pairs, comments
```

**How it works**: `init.lua` loads the `config/` modules, then `config/lazy.lua`
bootstraps the lazy.nvim plugin manager, which auto-discovers and loads every file
in `lua/plugins/`.

---

## Key Bindings

Leader key is **Space**.

### General
| Key | Action |
|-----|--------|
| `Space w` | Save file |
| `Space q` | Quit |
| `Esc` | Clear search highlight |
| `Ctrl+h/j/k/l` | Navigate between splits |
| `Shift+h / Shift+l` | Previous / next buffer |
| `gcc` | Toggle comment (line) |
| `gc` (visual) | Toggle comment (selection) |

### File Under Cursor
| Key | Action |
|-----|--------|
| `gf` | Open file under cursor (current window) |
| `Space gf` | Open file under cursor in vertical split |

### File Navigation (Telescope)
| Key | Action |
|-----|--------|
| `Space ff` | Find files |
| `Space fg` | Live grep (search text across files) |
| `Space fb` | Open buffers |
| `Space fr` | Recent files |
| `Space /` | Search in current buffer |
| `Space fs` | Document symbols |
| `Space fd` | Diagnostics |

### LSP (when a language server is active)
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `Space rn` | Rename symbol |
| `Space ca` | Code action |
| `Space D` | Type definition |
| `[d / ]d` | Previous / next diagnostic |
| `Space e` | Show diagnostic float |

### Completion (in insert mode)
| Key | Action |
|-----|--------|
| `Tab / Shift+Tab` | Navigate completion menu |
| `Enter` | Confirm selection |
| `Ctrl+Space` | Trigger completion manually |
| `Ctrl+e` | Close completion menu |
| `Ctrl+b / Ctrl+f` | Scroll docs |

### Git
| Key | Action |
|-----|--------|
| `]h / [h` | Next / previous git hunk |
| `Space gp` | Preview hunk |
| `Space gb` | Blame line |

### Discovery
| Key | Action |
|-----|--------|
| `Space ?` | Show buffer-local keymaps |
| (just pause after Space) | **which-key** popup shows all available bindings |

---

## How to Add Syntax Highlighting for a New Language

Treesitter handles syntax highlighting. To add a language:

1. Open `~/.config/nvim/lua/plugins/treesitter.lua`
2. Add the language name to the `ensure_installed` list
3. Restart Neovim (or run `:TSInstall <language>`)

With `auto_install = true` (already set), Treesitter will also auto-install
parsers when you open a file of a recognized type.

Full list of supported languages: run `:TSInstallInfo` in Neovim.

---

## How to Add IDE Features (LSP) for a New Language

Mason auto-installs language servers. To add one:

1. Open `~/.config/nvim/lua/plugins/lsp.lua`
2. Add the server name to `ensure_installed` (e.g., `"rust_analyzer"` for Rust)
3. Restart Neovim — Mason installs it, mason-lspconfig auto-enables it

**Find server names**: Run `:Mason` for an interactive browser, or see
[nvim-lspconfig server list](https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md).

Common servers:
| Language | Server name |
|----------|-------------|
| Python | `pyright` |
| TypeScript/JS | `ts_ls` |
| Go | `gopls` |
| Lua | `lua_ls` |
| Rust | `rust_analyzer` |
| C/C++ | `clangd` |
| CSS | `cssls` |
| HTML | `html` |
| JSON | `jsonls` |
| YAML | `yamlls` |
| Bash | `bashls` |
| Docker | `dockerls` |

To customize a specific server's settings, add a `vim.lsp.config()` call in
`lsp.lua` (see the `lua_ls` example already there).

---

## How to Add a New Plugin

1. Create a new file in `~/.config/nvim/lua/plugins/` (e.g., `myplugin.lua`)
2. Return a plugin spec table:

```lua
-- lua/plugins/myplugin.lua
return {
  "author/plugin-name",        -- GitHub repo
  event = "VeryLazy",          -- when to load (optional, for performance)
  opts = {                     -- passed to plugin's setup() function
    some_option = true,
  },
}
```

3. Restart Neovim — lazy.nvim auto-discovers and installs it

**Or** add it to an existing file by returning a list:
```lua
return {
  { "plugin/one", opts = {} },
  { "plugin/two", opts = {} },
}
```

### Useful lazy-loading triggers
- `event = "VeryLazy"` — load after UI is ready
- `event = "InsertEnter"` — load when entering insert mode
- `event = { "BufReadPost", "BufNewFile" }` — load when opening a file
- `cmd = "CommandName"` — load when running a command
- `keys = { { "<leader>x", ... } }` — load on keypress
- `ft = "python"` — load for specific filetypes

---

## How to Add Custom Keybindings

Edit `~/.config/nvim/lua/config/keymaps.lua`. Syntax:

```lua
vim.keymap.set("n", "<leader>x", "<cmd>SomeCommand<CR>", { desc = "Description" })
--             mode  key          action                    options
```

Modes: `"n"` = normal, `"i"` = insert, `"v"` = visual, `"x"` = visual block

---

## How to Change the Colorscheme

Edit `~/.config/nvim/lua/plugins/colorscheme.lua`. Change the plugin and
`vim.cmd.colorscheme()` call. Popular themes:
- `folke/tokyonight.nvim` (current)
- `catppuccin/nvim`
- `rebelot/kanagawa.nvim`
- `EdenEast/nightfox.nvim`
- `rose-pine/neovim`

---

## How to Change Core Settings

Edit `~/.config/nvim/lua/config/options.lua`. Examples:
- Tab width: change `tabstop`, `shiftwidth`, `softtabstop`
- Line numbers: toggle `number`, `relativenumber`
- Line wrapping: set `wrap = true`

---

## Plugin Manager Commands

| Command | Action |
|---------|--------|
| `:Lazy` | Open lazy.nvim dashboard |
| `:Lazy sync` | Install/update/clean all plugins |
| `:Lazy update` | Update plugins |
| `:Lazy health` | Check plugin health |
| `:Mason` | Open Mason dashboard (LSP servers) |
| `:TSInstallInfo` | Show treesitter parser status |
| `:checkhealth` | Full Neovim health check |

---

## Architecture Overview

```
You type code
    → Treesitter parses it into a syntax tree → colorful highlighting
    → LSP server analyzes it → diagnostics, completions, go-to-def, etc.
    → nvim-cmp collects suggestions from LSP + snippets + buffer → completion menu
    → Telescope searches files/text/symbols using ripgrep + fd
```

- **lazy.nvim**: downloads and loads plugins (like a package manager)
- **Treesitter**: fast, accurate syntax highlighting (replaces old regex-based highlighting)
- **LSP** (Language Server Protocol): talks to language servers (pyright, gopls, etc.)
  for IDE features. Neovim has a built-in LSP client.
- **Mason**: auto-installs language servers so you don't run `pip install` / `npm install` yourself
- **nvim-cmp**: aggregates completions from LSP, snippets, buffer words, file paths
