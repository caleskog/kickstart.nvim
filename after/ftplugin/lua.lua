--- Set up keybindings for Lua files
local key = Core.utils.keymap
key.map('n', '<leader>x', ':.lua<CR>', 'Lua: run line')
key.map('v', '<space>x', ':lua<CR>', 'Lua: run selection')

--- Set up Premake autocompletion
-- local cmp_premake = require('cmp/sources/premake5')
-- cmp_premake.setup()
