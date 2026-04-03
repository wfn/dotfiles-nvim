# Neovim Config Testing

> Regression and functionality test suite. Run after upgrades, plugin changes, or
> config modifications to verify nothing is broken.
>
> All tests use `nvim --headless` and can be run from a terminal without a GUI.

---

## Quick Smoke Test

Fastest check — startup with no errors:

```sh
nvim --headless -c 'lua print("OK")' -c 'qa!'
```

Should print `OK` with nothing on stderr.

---

## Full Test Suite

### 1. Clean Startup (no errors or deprecation warnings)

```sh
nvim --headless -c 'lua vim.defer_fn(function()
  local msgs = vim.api.nvim_exec2("messages", {output=true}).output
  print(msgs ~= "" and "MESSAGES:\n"..msgs or "CLEAN STARTUP")
  vim.cmd("qa!")
end, 3000)' 2>&1
```

**Expected**: `CLEAN STARTUP` — no deprecation warnings, no errors.

### 2. Treesitter Parsers Compiled

```sh
nvim --headless -c 'lua
  local parsers = vim.api.nvim_get_runtime_file("parser/*.so", true)
  print("Parser count:", #parsers)' -c 'qa!' 2>&1
```

**Expected**: 30+ parsers. (Includes bundled Neovim parsers + all from the config.)

### 3. Treesitter Highlighting Active

Tests that treesitter highlighting activates for multiple languages:

```sh
nvim --headless -c 'lua vim.defer_fn(function()
  local langs = {
    {ft="lua", code="local x = 1"},
    {ft="python", code="def foo(): pass"},
    {ft="go", code="package main"},
    {ft="javascript", code="const x = 1;"},
  }
  for _, l in ipairs(langs) do
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].filetype = l.ft
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {l.code})
    vim.api.nvim_set_current_buf(buf)
    vim.wait(500, function() return vim.treesitter.highlighter.active[buf] ~= nil end)
    local active = vim.treesitter.highlighter.active[buf] ~= nil
    print(l.ft .. ": " .. (active and "OK" or "FAIL"))
  end
  vim.cmd("qa!")
end, 2000)' 2>&1
```

**Expected**: All languages print `OK`.

### 4. LSP Attaches to a File

Opens a Lua file from this config and waits for lua_ls to attach:

```sh
nvim --headless ~/.config/nvim/lua/config/keymaps.lua -c 'lua vim.defer_fn(function()
  local clients = vim.lsp.get_clients({bufnr=0})
  print("LSP clients:", #clients)
  for _, c in ipairs(clients) do print("  " .. c.name) end
  vim.cmd("qa!")
end, 12000)' 2>&1
```

**Expected**: `LSP clients: 1` with `lua_ls` listed. Takes ~10s for the server to
start — the `12000` ms delay accounts for this.

### 5. Diagnostic Keymaps (no deprecation)

```sh
nvim --headless -c 'lua vim.defer_fn(function()
  local ok1 = pcall(vim.diagnostic.jump, {count=1})
  print("diagnostic.jump forward:", ok1)
  local ok2 = pcall(vim.diagnostic.jump, {count=-1})
  print("diagnostic.jump backward:", ok2)
  local ok3 = pcall(vim.diagnostic.open_float)
  print("diagnostic.open_float:", ok3)
  local msgs = vim.api.nvim_exec2("messages", {output=true}).output
  print("Deprecation warnings:", (msgs:find("[Dd]eprecated") and "YES" or "NONE"))
  vim.cmd("qa!")
end, 2000)' 2>&1
```

**Expected**: All three `true`, deprecation warnings `NONE`.

### 6. Completion Engine Loads

```sh
nvim --headless -c 'lua vim.defer_fn(function()
  local ok1 = pcall(require, "cmp")
  print("nvim-cmp:", ok1 and "OK" or "FAIL")
  local ok2 = pcall(require, "luasnip")
  print("luasnip:", ok2 and "OK" or "FAIL")
  vim.cmd("qa!")
end, 3000)' 2>&1
```

**Expected**: Both `OK`.

### 7. Telescope Pickers Open Without Error

Actually opens Telescope pickers (find_files, live_grep, buffers), which creates
buffers with custom filetypes (TelescopePrompt, TelescopeResults). Verifies that
treesitter's FileType autocmd doesn't crash on these non-parser filetypes.

```sh
nvim --headless -c 'lua vim.defer_fn(function()
  local builtin = require("telescope.builtin")
  local results = {}
  for _, picker in ipairs({"find_files", "live_grep", "buffers"}) do
    local ok, err = pcall(builtin[picker], {cwd = vim.fn.expand("~/.config/nvim")})
    results[picker] = ok
    print(picker .. ": " .. (ok and "OK" or "FAIL: " .. tostring(err)))
    if ok then pcall(vim.cmd, "close") end
  end
  vim.defer_fn(function()
    local msgs = vim.api.nvim_exec2("messages", {output=true}).output
    local has_parser_err = msgs:find("Parser could not be created")
    print("Treesitter parser errors:", has_parser_err and "YES" or "NONE")
    vim.cmd("qa!")
  end, 1000)
end, 2000)' 2>&1
```

**Expected**: All pickers `OK`, treesitter parser errors `NONE`.

### 8. Editor Plugins Load

```sh
nvim --headless -c 'lua vim.defer_fn(function()
  local plugins = {
    "gitsigns", "which-key", "lualine", "ibl",
    "nvim-autopairs", "Comment", "tokyonight",
  }
  for _, p in ipairs(plugins) do
    local ok = pcall(require, p)
    print(p .. ": " .. (ok and "OK" or "FAIL"))
  end
  vim.cmd("qa!")
end, 3000)' 2>&1
```

**Expected**: All `OK`.

### 9. Keymaps Registered

```sh
nvim --headless -c 'lua vim.defer_fn(function()
  local expected = {"[d", "]d", " w", " q", " ff", " fg", " fb", " e"}
  local maps = vim.api.nvim_get_keymap("n")
  local found = {}
  for _, m in ipairs(maps) do found[m.lhs] = true end
  for _, k in ipairs(expected) do
    print(k .. ": " .. (found[k] and "OK" or "MISSING"))
  end
  vim.cmd("qa!")
end, 3000)' 2>&1
```

**Expected**: All `OK`.

### 10. Health Check

```sh
nvim --headless -c 'lua vim.defer_fn(function()
  local ok = pcall(vim.cmd, "checkhealth vim.lsp")
  print("checkhealth vim.lsp:", ok and "OK" or "FAIL")
  vim.cmd("qa!")
end, 5000)' 2>&1
```

**Expected**: `OK`.

---

## Run All Tests at Once

Copy-paste this to run the full suite. Each test prints a header line:

```sh
echo "=== 1. Clean Startup ===" && \
nvim --headless -c 'lua vim.defer_fn(function() local m=vim.api.nvim_exec2("messages",{output=true}).output; print(m~="" and "MESSAGES:\n"..m or "CLEAN STARTUP"); vim.cmd("qa!") end, 3000)' 2>&1 && \
echo "=== 2. Parser Count ===" && \
nvim --headless -c 'lua local p=vim.api.nvim_get_runtime_file("parser/*.so",true); print("Parsers:",#p)' -c 'qa!' 2>&1 && \
echo "=== 3. TS Highlighting ===" && \
nvim --headless -c 'lua vim.defer_fn(function() for _,l in ipairs({{ft="lua",code="local x=1"},{ft="python",code="def f():pass"},{ft="go",code="package main"},{ft="javascript",code="const x=1;"}}) do local b=vim.api.nvim_create_buf(false,true);vim.bo[b].filetype=l.ft;vim.api.nvim_buf_set_lines(b,0,-1,false,{l.code});vim.api.nvim_set_current_buf(b);vim.wait(500,function() return vim.treesitter.highlighter.active[b]~=nil end);print(l.ft..": "..(vim.treesitter.highlighter.active[b]~=nil and "OK" or "FAIL")) end;vim.cmd("qa!") end,2000)' 2>&1 && \
echo "=== 4. LSP Attach ===" && \
nvim --headless ~/.config/nvim/lua/config/keymaps.lua -c 'lua vim.defer_fn(function() local c=vim.lsp.get_clients({bufnr=0});print("LSP clients:",#c);for _,x in ipairs(c) do print("  "..x.name) end;vim.cmd("qa!") end,12000)' 2>&1 && \
echo "=== 5. Diagnostics ===" && \
nvim --headless -c 'lua vim.defer_fn(function() print("jump fwd:",pcall(vim.diagnostic.jump,{count=1}));print("jump back:",pcall(vim.diagnostic.jump,{count=-1}));print("open_float:",pcall(vim.diagnostic.open_float));local m=vim.api.nvim_exec2("messages",{output=true}).output;print("deprecations:",m:find("[Dd]eprecated") and "YES" or "NONE");vim.cmd("qa!") end,2000)' 2>&1 && \
echo "=== 6. Completion ===" && \
nvim --headless -c 'lua vim.defer_fn(function() print("cmp:",pcall(require,"cmp") and "OK" or "FAIL");print("luasnip:",pcall(require,"luasnip") and "OK" or "FAIL");vim.cmd("qa!") end,3000)' 2>&1 && \
echo "=== 7. Telescope Pickers ===" && \
nvim --headless -c 'lua vim.defer_fn(function() local b=require("telescope.builtin");for _,p in ipairs({"find_files","live_grep","buffers"}) do local ok=pcall(b[p],{cwd=vim.fn.expand("~/.config/nvim")});print(p..": "..(ok and "OK" or "FAIL"));if ok then pcall(vim.cmd,"close") end end;vim.defer_fn(function() local m=vim.api.nvim_exec2("messages",{output=true}).output;print("parser errors: "..(m:find("Parser could not be created") and "YES" or "NONE"));vim.cmd("qa!") end,1000) end,2000)' 2>&1 && \
echo "=== 8. Editor Plugins ===" && \
nvim --headless -c 'lua vim.defer_fn(function() for _,p in ipairs({"gitsigns","which-key","lualine","ibl","nvim-autopairs","Comment","tokyonight"}) do print(p..": "..(pcall(require,p) and "OK" or "FAIL")) end;vim.cmd("qa!") end,3000)' 2>&1 && \
echo "=== 9. Keymaps ===" && \
nvim --headless -c 'lua vim.defer_fn(function() local f={};for _,m in ipairs(vim.api.nvim_get_keymap("n")) do f[m.lhs]=true end;for _,k in ipairs({"[d","]d"," w"," q"," ff"," fg"," fb"," e"}) do print(k..": "..(f[k] and "OK" or "MISSING")) end;vim.cmd("qa!") end,3000)' 2>&1 && \
echo "=== 10. Health ===" && \
nvim --headless -c 'lua vim.defer_fn(function() print("checkhealth:",pcall(vim.cmd,"checkhealth vim.lsp") and "OK" or "FAIL");vim.cmd("qa!") end,5000)' 2>&1 && \
echo "=== DONE ==="
```

Total runtime: ~30–40 seconds (mostly waiting for LSP in test 4).

---

## When to Run Tests

- After upgrading Neovim (`brew upgrade neovim`)
- After running `:Lazy update`
- After modifying any file in `lua/plugins/` or `lua/config/`
- After adding a new language (treesitter parser or LSP server)
- Smoke test (#1) is enough for minor keymaps/options changes
