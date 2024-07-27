---@author caleskog
---@description Completion API for nvim-cmp regarding premake5.
---@version 0.0.1

local Json = require('plenary.json')

local M = {
    PREMANE_NAME = 'premake5',
    API_DATA = vim.fn.stdpath('data') .. '/cmp_api',
    API_CACHE = vim.fn.stdpath('cache') .. '/cmp_api',
    api_filepath = M.API_CACHE .. '/' .. M.PREMAKE_NAME .. '_api_completions.lua',
}

---@alias caleskog.cmp.Scope
---| '"project"' # The field applies to workspaces and projects
---| '"config"' # The field applies to workspaces, projects, and individual build configurations
--
---@alias caleskog.cmp.Kind
---| '"string"' # A simple string value.
---| '"path"' # A file system path. The value will be made into an absolute path, but no wildcard expansion will be performed.
---| '"file"' # One or more file names. Wilcard expansion will be performed, and the results made absolute. Implies a list.
---| '"directory"' # One of more directory names. Wildcard expansion will be performed, and the results made absolute. Implies a list.
---| '"mixed"' # A mix of simple string values and file system paths. Values which contain a directory separator ("/") will be made absolute; other values will be left intact.
---| '"table"' # A table of values. If the input value is not a table, it is wrapped in one.
--
---@class caleskog.cmp.ApiFunction
---@field name string The API name of the new field. This is used to create a global function with the same name, and so should follow Lua symbol naming conventions.
---@field scope caleskog.cmp.Scope The scoping level at which this value can be used.
---@field kind caleskog.cmp.Kind The type of values that can be stored into this field.
---@field allowed? table|function|nil An array of valid values for this field, or a function which accepts a value as input and returns the canonical value as a result, or nil if the input value is invalid.
---@field tokens? boolean A boolean indicating whether token expansion should be performed for this function.
---@field pathVars? boolean A boolean indicating whether path variables should be expanded for this function.
---@field deprecated? boolean A boolean indicating whether this field is deprecated.
---@field description? string A description of the field, for use in the help system.

---@param path string Path to the `_premake_init.lua` file.
---@return table table with extracted `premake.api.register` calls.
---@return string string The content of the `_premake_init.lua` file.
---@usage local api = extract_premake_api('path/to/_premake_init.lua')
function M.extract_premake_api(path)
    local content = ""
    local api_functions = {}
    local file = io.open(path, 'r')
    if file then
        ---@type string
        content = file:read('*a')
        api_functions = M.get_registed_api_functions(content)
        file:close()
    end
    return api_functions, content
end

--- Get all registered API functions.
---Extracting `premake.api.register` calls from `premake-core/src/_premake_init.lua`
---@param content string The content of the `_premake_init.lua` file.
---@return table<caleskog.cmp.ApiFunction> # Table with extracted and parsed `premake.api.register` calls.
function M.get_registed_api_functions(content)
    ---@type table<caleskog.cmp.ApiFunction>
    local api = {}
    -- See this link for fields in the register call: https://github.com/premake/premake-core/blob/master/src/base/api.lua#L239
    local register_pattern = 'api%.register%s*%b{}' .. '|api%.register%s*%((.-%)%)' -- Also matches calls without curly brackets
    for api_func in content:gmatch(register_pattern) do
        ---@type caleskog.cmp.ApiFunction
        local api_data = loadstring("return " .. api_func)()
        if api_data.name then
            -- As I don't have the `premake-core` source code, it's not possilbe to parse the allowed fields if they are functions.
            if type(api_data.allowed) == "function" then
                api_data.allowed = nil
            end
            table.insert(api, api_data)
        end
    end
    -- If a registered functions are deprecated, add the `deprecated` and "description" fields to the API function.
    -- This is to avoid completions for deprecated functions
    local deprecated_pattern = 'api%.deprecateValue%s*%(%s*"([^"]+)"%s*,%s*"([^"]+)"'
    for api_deprecated in content:gmatch(deprecated_pattern) do
        for _, api_func in ipairs(api) do
            if api_func.name == api_deprecated[0] then
                api_func.deprecated = true
                api_func.description = api_deprecated[1]
            end
        end
    end
    return api
end

--- Generate a Lua file with completion metadata for `premake.api.register` calls to be used with `nvim-cmp`.
-- Downloading the `premake-core` source code from its Github repository, and then searches for the `_premake_init.lua` file.
-- The function parses the `_premake_init.lua` file and looks for `api.register` calls. All registered API functions are
-- saved into a table and returned to the caller.
---@param repo string GitHub repository name in the form `username/repo`.
---@param path string Path to the `_premake_init.lua` file. Starting from the root of the repository.
---@param filename? string The name of the Lua file to save the metadata to. Default is `<NVIM_DATA>/cmp_api/<PREMAKE_NAME>-api_completions.lua`
function M.generate_cmp_metadata(repo, path, filename)
    M.api_filepath = filename or M.api_filepath
    M.download_premake_file(repo, path)
    if not M.api_filepath then
        vim.notify('Could not download `' .. repo .. '/' .. path .. '` from Github', vim.log.levels.ERROR)
        return nil
    end
    local _, api_functions_str = M.extract_premake_api(M.api_filepath)
    local file = io.open(M.api_filepath, 'w')
    if file then
        file:write('---Generated API file for ' .. M.PREMAKE_NAME .. ' completions\n')
        file:write(api_functions_str)
        file:close()
    end
end

--- Estimate short SHA commit from the installed `premake` binary.
--- The function tries to extract the short SHA commit from the output of `premake5 --help`.
--- The function uses a set of patterns to match against the version string.
---@param short_sha string|nil The short SHA commit of the installed `premake` binary.
---@return string|nil short_sha The short SHA commit of the installed `premake` binary.
function M.retrieve_short_sha(short_sha)
    short_sha = short_sha or nil
    if short_sha then
        return short_sha
    end
    local premake_version = vim.fn.system('premake5 --help')
    -- Available version patterns to match against the output of `premake`
    local version_patterns = {
        'Release%s:%s[0-9]+%.[0-9]+git([a-z0-9]+)%.fc[0-9]+',
        'Source%s:%spremake%-[0-9%.]+%-[0-9]+%.[0-9]+git([a-z0-9]+)%.fc[0-9]+%.src%.rpm',
        'Release%s:%s[0-9]+%.[0-9]+git([a-z0-9]+)%.',
    }
    -- Extract the version from the output of `premake5 --help`.
    -- Use the first pattern that matches, testing the patterns in order.
    for _, pattern in ipairs(version_patterns) do
        local sha = premake_version:match(pattern)
        if sha then
            return sha
        end
    end
    vim.notify('Could not extract short SHA from `premake5 --help` string', vim.log.levels.ERROR)
    return nil
end

--- Retrieve the full SHA commit of the installed `premake` binary.
---@param repo string GitHub repository name in the form `username/repo`.
---@param short_sha string The short SHA commit of `premake` to use.
---@return string|nil full_sha The full SHA commit of the installed `premake` binary.
function M.retrieve_full_sha(repo, short_sha)
    local gh_api = 'https://api.github.com/repos/' .. repo .. '/commits/' .. short_sha
    local tmp = M.API_CACHE .. '/premake-core-' .. short_sha .. '.json'
    vim.fn.system('curl -L ' .. gh_api .. ' -o ' .. tmp)
    if not vim.fn.filereadable(tmp) then
        vim.notify('Could not retrieve response from Github API', vim.log.levels.ERROR)
        return nil
    end
    -- Parse the JSON response from the Github API
    local file = io.open(tmp, 'r')
    ---@diagnostic disable-next-line: need-check-nil
    local content = file:read('*a')
    ---@diagnostic disable-next-line: missing-parameter
    local json_string = Json.json_strip_comments(content)
    local json_data = vim.fn.json_decode(json_string)
    local full_sha = json_data.sha
    ---@diagnostic disable-next-line: need-check-nil
    file:close()

    if not full_sha then
        vim.notify('Could not retrieve full SHA from GitHub API', vim.log.levels.ERROR)
        return nil
    end
    return full_sha
end

--- Donwload specified source file from the `premake-core` GitHub repo with respect to installed `premake` version.
---@param repo string GitHub repository name in the form `username/repo`.
---@param path string Path to the `_premake_init.lua` file. Starting from the root of the repository.
---@param short_sha? string|nil The short SHA commit of `premake` to use. Default is `nil`, meaning it will try to find the commit that matches the installed `premake` binary.
---@return boolean boolean if the file was downloaded successfully.
function M.download_premake_file(repo, path, short_sha)
    short_sha = short_sha or nil
    short_sha = M.retrieve_short_sha(short_sha)
    local sha = M.retrive_full_sha(repo, short_sha)
    local gh_api = string.format('https://raw.githubusercontent.com/%s/%s/%s', repo, sha, path)
    local sourcefile = M.api_filepath
    vim.fn.system('curl -L ' .. gh_api .. ' -o ' .. M.api_filepath)
    if not vim.fn.filereadable(M.api_filepath) then
        return false
    end
    return true
end

return M
