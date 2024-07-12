-- File: util.lua
-- Author: caleskog
-- Description: Utility functions.

local M = {}

local notify = require('notify')

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
    _modes = { 'n', 'i', 'v', 'V', 'W', 's', 'S', 'Z', 'R', 't' },
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
        ---@diagnostic disable-next-line: missing-fields
        notify.notify("Invalid mode: '" .. mode .. "'", 'warning', {
            title = 'Utility Library',
        })
        return false
    end
    vim.keymap.set(M.Mode[mode], key, invoke, table.insert(opts, { desc = desc }))
    return true
end

---Map a key to a action, assuming the `invoke` variable holds an expression
---@param mode string
---@param key string
---@param invoke any
---@param desc? string
function M.emap(mode, key, invoke, desc)
    desc = desc or ''
    if not M.Mode[mode] then
        ---@diagnostic disable-next-line: missing-fields
        notify.notify("Invalid mode: '" .. mode .. "'", 'warning', {
            title = 'Utility Library',
        })
        return false
    end
    vim.keymap.set(M.Mode[mode], key, invoke, { desc = desc, expr = true })
    return true
end

---Map a key to a action, assuming the `invoke` variable holds a command
---@param mode string
---@param key string
---@param invoke any
---@param desc? string
function M.cmap(mode, key, invoke, desc)
    desc = desc or ''
    if not M.Mode[mode] then
        ---@diagnostic disable-next-line: missing-fields
        notify.notify("Invalid mode: '" .. mode .. "'", 'warning', {
            title = 'Utility Library',
        })
        return false
    end
    vim.keymap.set(M.Mode[mode], key, '<CMD>' .. invoke .. '<CR>', { desc = desc })
    return true
end

---Check if a module exists before requiring it
---@param name string Module name
function M.module_mxists(name)
    local status, _ = pcall(require, name)
    return status
end

---Generate a which-key register table for additional around/inside functionality.
---
---The following is an example of what it would produce:
---     M.WhichKey_ai("[A]rgument")
--- would produce the following which-key register table:
---     {
---         ["aA"] = "[a]round [A]rgument",
---         ["iA"] = "[i]nside [A]rgument",
---     }
---
---Note: The function `M.flatten` is needed if the function will be used more than once.
---
---@param identifier string Identifier name including the textobject id surrounded by [].
---@return table
function M.WhichKey_ai(identifier)
    local i, j = string.find(identifier, '%[.%]')
    if i == nil then
        return {}
    end
    local key = string.sub(identifier, i + 1, j - 1)
    return {
        ['a' .. key] = '[a]round ' .. identifier,
        ['i' .. key] = '[i]inside ' .. identifier,
    }
end

---Dump the content of a dictionary into a new file.
---
---@param dict table Dictionary to be written to file.
---@param filename? string Name of the dump file. Deafult: `'dict.dump'`
function M.dump_dict(dict, filename)
    filename = filename or 'dict.dump'
    local content = vim.inspect(dict)
    local file = io.open(filename, 'w')
    if not file then
        error('Could not open file ' .. filename .. 'for writing')
    end
    file:write(content)
    file:close()
end

---Flatten a dictionary of keys of type string (`[<string>]`).
---
---@param tlb table The table to be flattend
---@param depth? integer The depth to be considered. Default: `-1`
---@param parent_key? string Key from the parent table. Default: `""`
---@return table # The flattened table
function M.flatten(tlb, depth, parent_key)
    local flat_table = {}
    depth = depth or -1
    parent_key = parent_key or ''

    local function _flatten(t, current_depth, current_key)
        for k, v in pairs(t) do
            local new_key = current_key
            if type(k) ~= 'number' then
                new_key = current_key .. (current_key ~= '' and '.' or '') .. k
            end

            if type(v) == 'table' and current_depth ~= depth then
                _flatten(v, depth + 1, new_key)
            else
                flat_table[new_key] = v
            end
        end
    end

    _flatten(tlb, depth + 1, parent_key)
    return flat_table
end

return M
