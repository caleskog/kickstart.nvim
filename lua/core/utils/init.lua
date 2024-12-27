---@class caleskog.nvim.core.Utils
---@field keymap caleskog.nvim.core.utils.Keymap
---@field module caleskog.nvim.core.utils.Module
---@field tbl caleskog.nvim.core.utils.Tbl
---@field file caleskog.nvim.core.utils.File
local M = {}

setmetatable(M, {
    __index = function(t, k)
        local ok, mod = pcall(require, 'core.utils.' .. k)
        if not ok then
            error('Module ' .. k .. ' not found in core.utils')
        end
        t[k] = mod
        return t[k]
    end,
})

return M
