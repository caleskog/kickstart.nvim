---@class caleskog.nvim.core.utils.Keymap
local M = {}

---Available modes for the map functions
---Example:
---     M.Mode['nv'] results in { 'n', 'v' }
---     M.Mode['iv'] results in { 'i', 'v' }
---     M.Mode['ntV'] results in { 'n', 't', 'V' }
---Note:
---     'W' => 'ctrl-v'
---     'Z' => 'ctrl-s'
---
---@class Modes
M.Mode = setmetatable({
    -- See :h mode()
    _modes = { 'n', 'i', 'v', 'V', 'W', 's', 'S', 'Z', 'R', 't', 'o', 'x' },
}, {
    ---Index function
    ---@param self table
    ---@param key string
    __index = function(self, key)
        local exists = 0
        for i = 1, #key do
            for _, mode in ipairs(self._modes) do
                if key:sub(i, i) == mode then
                    exists = exists + 1
                end
            end
        end
        if exists == string.len(key) then
            local ret_tbl = {}
            for c in key:gmatch('.') do
                table.insert(ret_tbl, c)
            end
            return ret_tbl
        end
        return false
    end,
    __newindex = nil,
})
M.NORMAL = { 'n' }
M.INSERT = { 'i' }
M.VISUAL = { 'v' }
M.TERMINAL = { 't' }

---Map a key to a action.
---@param mode string
---@param key string
---@param invoke any
---@param desc? string
---@param opts? vim.keymap.set.Opts
function M.map(mode, key, invoke, desc, opts)
    desc = desc or ''
    opts = opts or {}
    if not M.Mode[mode] then
        vim.notify("Invalid mode: '" .. mode .. "'", 'warning', {
            title = 'Utility Library',
        })
        return false
    end
    opts.desc = desc
    vim.keymap.set(M.Mode[mode], key, invoke, opts)
    return true
end

---Map a key to a action, assuming the `invoke` variable holds an expression
---Essentially a wrapper of `util.map(...)`
---@param mode string
---@param key string
---@param invoke string
---@param desc? string
function M.emap(mode, key, invoke, desc)
    return M.map(mode, key, invoke, desc, { expr = true })
end

---Map a key to a action, assuming the `invoke` variable holds a command
---Essentially a wrapper of `util.map(...)`
---@param mode string
---@param key string
---@param invoke string
---@param desc? string
function M.cmap(mode, key, invoke, desc)
    return M.map(mode, key, '<CMD>' .. invoke .. '<CR>', desc)
end

---Map a key to a action, assuming the `invoke` variable holds a function
---Essentially a wrapper of `util.map(...)`
---@param mode string
---@param key string
---@param invoke function
---@param desc? string
---@param opts? vim.keymap.set.Opts
function M.fmap(mode, key, invoke, desc, opts)
    return M.map(mode, key, invoke, desc, opts)
end

return M
