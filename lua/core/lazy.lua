---@class caleskog.nvim.core.Lazy
local M = {}

local keymap = Core.utils.keymap

---Create a new key mapping for Lazy's `keys` configuration.
---@param mode string
---@param key string
---@param invoke string|function
---@param desc? string
---@param opts? LazyKeysBase
---@return LazyKeysSpec
function M.map(mode, key, invoke, desc, opts)
    desc = desc or ''
    opts = opts or {}
    opts.desc = desc
    local parsed_mode = keymap.parse_mode(mode)
    if not parsed_mode then
        vim.notify("Invalid mode: '" .. mode .. "'", 'warning', {
            title = 'Core.Lazy',
        })
        return {}
    end
    ---@type LazyKeysSpec
    return {
        mode = parsed_mode,
        lhs = key,
        rhs = invoke,
        desc = desc,
        opts = opts,
    }
end

---Create a new key mapping for Lazy's `keys` configuration.
---Assuming the `invoke` variable holds an expression
---Essentially a wrapper of `keymap.map(...)`
---@param mode string
---@param key string
---@param invoke string
---@param desc? string
---@param opts? LazyKeysBase
---@return LazyKeysSpec
function M.emap(mode, key, invoke, desc, opts)
    opts = opts or {}
    opts.expr = true
    return M.map(mode, key, invoke, desc, opts)
end

---Create a new key mapping for Lazy's `keys` configuration.
---Assuming the `invoke` variable holds a command
---Essentially a wrapper of `keymap.map(...)`
---@param mode string
---@param key string
---@param invoke string
---@param desc? string
---@param opts? LazyKeysBase
---@return LazyKeysSpec
function M.cmap(mode, key, invoke, desc, opts)
    opts = opts or {}
    return M.map(mode, key, '<CMD>' .. invoke .. '<CR>', desc, opts)
end

---Create a new key mapping for Lazy's `keys` configuration.
---Assuming the `invoke` variable holds a function
---Essentially a wrapper of `keymap.map(...)`
---@param mode string
---@param key string
---@param invoke function
---@param desc? string
---@param opts? LazyKeysBase
---@return LazyKeysSpec
function M.fmap(mode, key, invoke, desc, opts)
    return M.map(mode, key, invoke, desc, opts)
end

---Create a new key mapping for Lazy's `keys` configuration using filetype-local mappings.
---@param ft string|string[]
---@param mode string
---@param key string
---@param invoke string|function
---@param desc? string
---@param opts? LazyKeysBase
---@return LazyKeysSpec
function M.bmap(ft, mode, key, invoke, desc, opts)
    desc = desc or ''
    opts = opts or {}
    opts.desc = desc
    opts.ft = ft
    return M.map(mode, key, invoke, desc, opts)
end

---Create a new key mapping for Lazy's `keys` configuration using filetype-local mappings.
---Assuming the `invoke` variable holds an expression
---Essentially a wrapper of `keymap.map(...)`
---@param ft string|string[]
---@param mode string
---@param key string
---@param invoke string
---@param desc? string
---@param opts? LazyKeysBase
---@return LazyKeysSpec
function M.ebmap(ft, mode, key, invoke, desc, opts)
    opts = opts or {}
    opts.expr = true
    return M.bmap(ft, mode, key, invoke, desc, opts)
end

---Create a new key mapping for Lazy's `keys` configuration using filetype-local mappings.
---Assuming the `invoke` variable holds a command
---Essentially a wrapper of `keymap.map(...)`
---@param ft string|string[]
---@param mode string
---@param key string
---@param invoke string
---@param desc? string
---@param opts? LazyKeysBase
---@return LazyKeysSpec
function M.cbmap(ft, mode, key, invoke, desc, opts)
    opts = opts or {}
    return M.bmap(ft, mode, key, '<CMD>' .. invoke .. '<CR>', desc, opts)
end

---Create a new key mapping for Lazy's `keys` configuration using filetype-local mappings.
---Assuming the `invoke` variable holds a function
---Essentially a wrapper of `keymap.map(...)`
---@param ft string|string[]
---@param mode string
---@param key string
---@param invoke function
---@param desc? string
---@param opts? LazyKeysBase
---@return LazyKeysSpec
function M.fbmap(ft, mode, key, invoke, desc, opts)
    return M.bmap(ft, mode, key, invoke, desc, opts)
end

return M
