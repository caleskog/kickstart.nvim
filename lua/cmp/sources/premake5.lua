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
    -- TODO: Fix so that this only happen when it needs to. Now it will download it every time Neovim starts
    if not premake.api_filepath then
        premake.generate_cmp_metadata('premake/premake-core', 'src/_premake_init.lua')
    end

    local source = {}

    source.new = function()
        local self = setmetatable({}, { __index = source })
        M.api_completions = nil
        if vim.fn.filereadable(premake.api_filepath) then
            M.api_completions = loadfile(premake.api_filepath)()
        end
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
        -- Gracefully exit if the API file is not
        if not M.api_completions then
            return
        end
        ---@type table<lsp.CompletionItem>
        local items = {}

        ---@type table<caleskog.cmp.ApiFunction>
        local api_items = loadstring(M.api_completions)()
        for api_item in api_items do
            -- TODO: Change item based on kind and other properties; can be found here: https://github.com/premake/premake-core/blob/master/src/base/api.lua#L239
            if api_item.name  then
                ---@type lsp.CompletionItem
                local item = {
                    label = api_item.name,
                    detail = api_item.detail,
                }
                if api_item.deprecated then
                    item.deprecated = api_item.deprecated
                    item.documentation = { kind = 'markdown', value = api_item.description }
                end
                table.insert(items, item)
            end
        end
        callback({ items = items })
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
