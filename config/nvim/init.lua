LAZY_PLUGIN_SPEC = {}

function spec(item)
  table.insert(LAZY_PLUGIN_SPEC, { import = item })
end


require "config.vimOpt"
require "config.keymap"

-- spec "user.attempt"
require "config.lazy"
require "config.commands"
require "config.autocmds"
