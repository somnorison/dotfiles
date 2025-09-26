LAZY_PLUGIN_SPEC = {}

function spec(item)
  table.insert(LAZY_PLUGIN_SPEC, { import = item })
end

helpers = require "utils.helpers"
execs = require "utils.execs"

spec "plugin.whichkey"
spec "plugin.telescope"
spec "plugin.luaconsole"

vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- spec "user.attempt"
require "config.lazy"

--
require "config.vimOpt"
require "config.keymap"
require "config.commands"
require "config.autocmds"

