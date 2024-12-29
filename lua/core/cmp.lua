---@class caleskog.nvim.core.Cmp
local M = {}

---Merge two keymaps used in `nvim-cmp`'s `opts.mapping`
---Taken from: [nvim-cmp](https.github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/mapping.lua)
---@param base table The base keymap
---@param override table The keymap to override the base keymap
---@return table The merged keymap
function M.merge_keymaps(base, override)
    local misc = require('cmp.utils.misc')
    local keymap = require('cmp.utils.keymap')

    local normalized_base = {}
    for k, v in pairs(base) do
        normalized_base[keymap.normalize(k)] = v
    end

    local normalized_override = {}
    for k, v in pairs(override) do
        normalized_override[keymap.normalize(k)] = v
    end

    return misc.merge(normalized_base, normalized_override)
end

return M
