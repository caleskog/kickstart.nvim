---@author caleskog
---@description Completion API for nvim-cmp regarding premake5.
---@version 0.0.1

local premake = require('cmp.api.premake5')

---Custom source for `nvim-cmp`
---Example: https://github.com/saadparwaiz1/cmp_luasnip/blob/master/lua/cmp_luasnip/init.lua
---See `:help cmp-develop` for more information on how to make custom sources.
local M = {}
local registered = false

M.setup = function()
    -- Skip if already registered
    if registered then
        return
    end
    registered = true

    -- Generate completion api if not already generated
    if not premake.api_filepath then
        premake.generate_cmp_metadata(vim.fn.expand('~/.config/nvim/lua/after/ftplugin/premake.lua'))
    end

    local source = {}

    source.new = function()
        local self = setmetatable({}, { __index = source })
        return self
    end

    ---Return the debug name of this source (optional).
    ---@return string
    function source:get_debug_name()
        return premake.PREMAKE_NAME .. 'API'
    end

    ---Return whether this source is available in the current context or not (optional).
    ---@return boolean
    function source:is_available()
        return true
    end

    ---Invoke completion (required).
    ---@param params cmp.SourceCompletionApiParams
    ---@param callback fun(response: lsp.CompletionResponse|nil)
    function source:complete(params, callback)
        local api_completions = require(premake.api_filepath)
        callback({
            items = metadata,
        })
    end

    ---Resolve completion item (optional). This is called right before the completion is about to be displayed.
    ---Useful for setting the text shown in the documentation window (`completion_item.documentation`).
    ---@param completion_item lsp.CompletionItem
    ---@param callback fun(completion_item: lsp.CompletionItem|nil)
    function source:resolve(completion_item, callback)
        callback(completion_item)
    end

    ---Executed after the item was selected.
    ---@param completion_item lsp.CompletionItem
    ---@param callback fun(completion_item: lsp.CompletionItem|nil)
    function source:execute(completion_item, callback)
        callback(completion_item)
    end

    ---Register souce to `nvim-cmp`
    require('cmp').register_source(premake.PREMAKE_NAME, source)
end

return M
