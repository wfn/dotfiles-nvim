-- Neovim configuration entry point
-- All config is in lua/config/ and lua/plugins/

-- Load core settings first (before plugins)
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Bootstrap and load plugins via lazy.nvim
require("config.lazy")
