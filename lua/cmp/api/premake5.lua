---@author caleskog
---@description Completion API for nvim-cmp regarding premake5.
---@version 0.0.1

local M = {
    PREMANE_NAME = 'premake5',
    API_DIR = vim.fn.stdpath('data') .. '/cmp_api',
    api_filepath = M.API_DIR .. '/' .. M.PREMAKE_NAME .. '_api_completions.lua',
}

---Function to extract `premake.api.register` calls from `premake-core/src/_premake_init.lua`
---@param path string Path to the `_premake_init.lua` file.
---@return table table with extracted `premake.api.register` calls.
---@return string string The content of the `_premake_init.lua` file.
---@usage local api = extract_premake_api('path/to/_premake_init.lua')
function M.extract_premake_api(path)
    local content = ""
    local api_functions = {}
    local register_pattern = "api.register%(?(%b{})"
    local file = io.open(path, 'r')
    if file then
        ---@type string
        content = file:read('*a')
        for api_func in content:gmatch(register_pattern) do
            local api_data = loadstring("return " .. api_func)()
            if api_data.name then
                table.insert(api_functions, api_data)
            end
        end
        file:close()
    end
    return api_functions, content
end

---Generate a Lua file with completion metadata for `premake.api.register` calls to be used with nvim-cmp.
---@param path string Path to the `_premake_init.lua` file.
---@param metadata_filename? string The name of the Lua file to save the metadata to. Default is `<NVIM_DATA>/cmp_api/<PREMAKE_NAME>_api_completions.lua`
function M.generate_cmp_metadata(path, metadata_filename)
    metadata_filename = metadata_filename or M.api_filepath
    local _, api_functions_str = M.extract_premake_api(path)
    M.api_filepath = metadata_filename
    local file = io.open(metadata_filename, 'w')
    if file then
        file:write('---Generated API file for ' .. M.PREMAKE_NAME .. ' completions\n')
        file:write(api_functions_str)
        file:close()
    end
end

return M
