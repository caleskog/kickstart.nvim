---@class caleskog.nvim.core.WhichKey
local M = {}

---Generate a which-key register table for additional around/inside functionality.
---
---Note: The function `M.flatten` is needed if the function will be used more than once.
---
---**Example 1:**
--- ```lua
--- M.gen_ai("[A]rgument")
--- ```
--- would produce the following which-key register table:
--- ```lua
--- {
---     ["aA"] = "[a]round [A]rgument",
---     ["iA"] = "[i]nside [A]rgument",
--- }
--- ```
---
---**Example 2:**
--- ```lua
--- M.gen_ai("Argument")
--- ```
--- would produce the following which-key register table:
--- ```lua
--- {
---     ["aA"] = "[a]round [A]rgument",
---     ["iA"] = "[i]nside [A]rgument",
--- }
--- ```
---
---@param mode string
---@param identifier string Identifier name including the textobject id surrounded by [].
---@return table<table<string>>
function M.gen_ai(mode, identifier)
    local i, j = identifier:find('%[.%]')
    local key = ''
    if i ~= nil then
        key = identifier:sub(i + 1, j - 1)
    else
        -- If no square brackets are found, use the first uppercase letter as the key
        key = identifier:match('%u')
    end
    return {
        { 'a' .. key, desc = '[a]round ' .. identifier, mode = mode },
        { 'i' .. key, desc = '[i]inside ' .. identifier, mode = mode },
    }
end

return M
