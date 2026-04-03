# Fresh Machine Setup

> Steps to set up this Neovim config on a new macOS machine from scratch.

---

## Prerequisites

| Dependency | Install | Why |
|------------|---------|-----|
| **Neovim 0.12+** | `brew install neovim` | The editor itself |
| **tree-sitter CLI** | `npm install -g tree-sitter-cli` | Compiles treesitter parsers for syntax highlighting |
| **ripgrep** | `brew install ripgrep` | Used by Telescope for live grep (`Space fg`) |
| **fd** | `brew install fd` | Used by Telescope for file finding (`Space ff`) |
| **A Nerd Font** | See below | Icons in statusline, file explorer, etc. |
| **Node.js / npm** | `brew install node` | For tree-sitter CLI and some LSP servers |
| **Git** | (pre-installed on macOS) | Plugin manager clones from GitHub |
| **C compiler** | `xcode-select --install` | Some treesitter parsers compile from C source |

### Nerd Font

A patched font is needed for icons. Install one via Homebrew:

```sh
brew install --cask font-jetbrains-mono-nerd-font
```

Then set your terminal emulator's font to "JetBrainsMono Nerd Font" (or whichever
you installed).

---

## Install Steps

```sh
# 1. Install Neovim and dependencies
brew install neovim ripgrep fd node
npm install -g tree-sitter-cli

# 2. Clone the config
git clone gitpersonal:wfn/nvim-config.git ~/.config/nvim
# (Or whatever remote URL / method you use)

# 3. Launch Neovim
nvim
```

On first launch:
- **lazy.nvim** bootstraps itself (auto-cloned from GitHub)
- All plugins are installed automatically
- Treesitter parsers compile in the background (may take 30–60 seconds)
- Mason installs LSP servers on first use (pyright, ts_ls, gopls, lua_ls)

Wait for the initial install to finish, then quit and reopen for a clean start.

---

## Verify the Setup

Run the smoke test:

```sh
nvim --headless -c 'lua print("OK")' -c 'qa!'
```

Or run the full test suite from `TESTING.md`:

```sh
# See TESTING.md § "Run All Tests at Once" for the full command
```

### Checklist

- [ ] `nvim --version` shows 0.12+
- [ ] `tree-sitter --version` shows 0.26+
- [ ] Opening a `.lua` file shows syntax highlighting
- [ ] `Space ff` opens the Telescope file finder
- [ ] `K` on a Lua symbol shows hover docs (LSP working)
- [ ] Tab in insert mode shows completion menu

---

## Troubleshooting First Install

**Plugins didn't install**: Open nvim and run `:Lazy sync`.

**Parsers failed to compile**: Ensure tree-sitter CLI is on PATH (`tree-sitter --version`).
If missing, run `npm install -g tree-sitter-cli`, then `:TSUpdate` inside Neovim.

**No LSP features**: Run `:Mason` — servers may still be installing. Check
`:checkhealth vim.lsp` for errors.

**No icons / broken symbols**: Make sure your terminal is using a Nerd Font.

**ripgrep / fd not found**: Telescope grep and file-find won't work. Install them:
`brew install ripgrep fd`.

See `USAGE_DETAILS.md` § "Troubleshooting" for more.

---

## Updating on an Existing Machine

```sh
# Update Neovim
brew upgrade neovim

# Update plugins (inside Neovim)
:Lazy sync

# Update treesitter parsers (inside Neovim)
:TSUpdate

# Update tree-sitter CLI
npm update -g tree-sitter-cli
```

After major Neovim version upgrades, run the test suite from `TESTING.md` to
check for regressions.
