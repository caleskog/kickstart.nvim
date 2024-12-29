---@class caleskog.nvim.core.Snacks
local M = {}

---@class caleskog.nvim.core.snacks.ToggleOpts
---@field bufnr number Buffer number
---@field name string Display name
---@field get fun():boolean Getter function
---@field set fun(state:boolean) Setter function

---Wrapper for `Snacks.toggle` that creates a new buffer-local toggle object.
---@param opts caleskog.nvim.core.snacks.ToggleOpts Configuration options
---@return snacks.toggle.Class The toggle object
function M.btoggle(opts)
    return Snacks.toggle({
        id = opts.name:lower():gsub('%W+', '_'):gsub('_+$', ''):gsub('^_+', '') .. '-' .. opts.bufnr,
        name = opts.name,
        get = opts.get,
        set = opts.set,
    })
end

return M
