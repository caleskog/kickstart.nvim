---@class caleskog.nvim.core.Core
---@field mini caleskog.nvim.core.Mini
---@field config caleskog.nvim.core.Config
local M = {}

setmetatable(M, {
    __index = function(t, k)
        ---@diagnostic disable-next-line: no-unknown
        t[k] = require('core.' .. k)
        return t[k]
    end,
})

---Register a new event for Lazy
---@param name string The name of the event
---@param event table<string> Combinations of events that constitute the new event
function M.new_event(name, event)
    -- Add support for the LazyFile event
    local Event = require('lazy.core.handler.event')
    Event.mappings[name] = { id = name, event = event }
    Event.mappings['User LazyFile'] = Event.mappings[name]
end

---Check if a plugin is loaded
---Taken from LazyVim: https://github.com/LazyVim/LazyVim/blob/d0c366e4d861b848bdc710696d5311dca2c6d540/lua/lazyvim/util/init.lua
---@param name string The name of the plugin
function M.is_loaded(name)
    local Config = require('lazy.core.config')
    return Config.plugins[name] and Config.plugins[name]._.loaded
end

---Execute a function when a plugin is loaded
---Taken from LazyVim: https://github.com/LazyVim/LazyVim/blob/d0c366e4d861b848bdc710696d5311dca2c6d540/lua/lazyvim/util/init.lua
---@param name string The name of the plugin
---@param fn fun(name:string) The function to be executed when the plugin is loaded
function M.on_load(name, fn)
    if M.is_loaded(name) then
        fn(name)
    else
        vim.api.nvim_create_autocmd('User', {
            pattern = 'LazyLoad',
            callback = function(event)
                if event.data == name then
                    fn(name)
                    return true
                end
            end,
        })
    end
end

---Schedule a function to be executed when the plugin is loaded
---@param name string The name of the plugin
---@param fn fun(name:string) The function to be executed when the plugin is loaded
function M.schedule_on_load(name, fn)
    M.on_load(name, function()
        vim.schedule(function()
            fn(name)
        end)
    end)
end

---Get a plugin by name
---@param name string The name of the plugin
function M.get_plugin(name)
    return require('lazy.core.config').spec.plugins[name]
end

---Get the local path of a plugin
---@param name string The name of the plugin
---@param path string? The path to append to the plugin path
function M.get_plugin_path(name, path)
    local plugin = M.get_plugin(name)
    path = path and '/' .. path or ''
    return plugin and (plugin.dir .. path)
end

---Check if a plugin is installed
---@param plugin string The name of the plugin
function M.has(plugin)
    return M.get_plugin(plugin) ~= nil
end

---Get the configuration of a plugin by name
---@param name string The name of the plugin
function M.opts(name)
    local plugin = M.get_plugin(name)
    if not plugin then
        return {}
    end
    local Plugin = require('lazy.core.plugin')
    return Plugin.values(plugin, 'opts', false)
end

return M
