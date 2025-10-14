LAZY_PLUGIN_SPEC = {}

function spec(item)
  table.insert(LAZY_PLUGIN_SPEC, { import = item })
end

helpers = require "bespoke.helpers"
execs = require "bespoke.execs"
statusline = require "bespoke.statusline"
pomodoro = require "bespoke.pomodoro"

spec "plugin.whichkey"
spec "plugin.telescope"
spec "plugin.luaconsole"
-- spec "plugin.nvim-tree"

vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- spec "user.attempt"
require "config.lazy"

--
require "config.vimOpt"
require "config.keymap"
require "config.commands"
require "config.autocmds"

pomodoro.configure()
statusline.configure()
