--- Set up keybindings for Lua files
local util = require('util')
util.map('n', '<leader>x', ':.lua<CR>', 'Lua: run line')
util.map('v', '<space>x', ':lua<CR>', 'Lua: run selection')

--- Set up Premake autocompletion
-- local cmp_premake = require('cmp/sources/premake5')
-- cmp_premake.setup()
