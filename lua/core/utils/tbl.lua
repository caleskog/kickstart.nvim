---@class caleskog.nvim.core.utils.Tbl
local M = {}

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
---@return table # The flattened table
function M.flatten(tlb, depth)
    depth = depth or 1

    return vim.iter(tlb):flatten(depth):totable()
end

---Check if a table contains a specific value
---
---@param tbl table
---@param val any
---@return boolean
function M.contains(tbl, val)
    for _, value in ipairs(tbl) do
        if value == val then
            return true
        end
    end
    return false
end

return M
