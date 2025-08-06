LAZY_PLUGIN_SPEC = {}

function spec(item)
  table.insert(LAZY_PLUGIN_SPEC, { import = item })
end

helpers = require "utils.helpers"

spec "plugin.whichkey"
spec "plugin.telescope"

-- spec "user.attempt"
require "config.vimOpt"
require "config.keymap"
require "config.lazy"
require "config.commands"
require "config.autocmds"

