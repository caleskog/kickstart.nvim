---@class caleskog.nvim.core.utils.Module
local M = {}

---Check if a module exists before requiring it
---@param name string Module name
function M.module_mxists(name)
    local status, _ = pcall(require, name)
    return status
end

return M
