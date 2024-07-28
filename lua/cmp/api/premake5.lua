---@author caleskog
---@description Completion API for nvim-cmp regarding premake5.
---@version 0.0.1

local http = require("socket.http")

local M = {
    PREMAKE_NAME = 'premake5',
    API_DATA = vim.fn.stdpath('data') .. '/cmp_api',
    API_CACHE = vim.fn.stdpath('cache') .. '/cmp_api',
}

--- Called when any field is accessed in the `M` table.
function M.initialize()
    vim.fn.mkdir(M.API_CACHE, 'p')
    vim.fn.mkdir(M.API_DATA, 'p')
end

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

--- Parse the provided lua file containing the `premake.api.register` calls. Retrive the necessary information from the registered API functions.
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
        -- convert ^I to tabs
        content = content:gsub("%^I", "\t")
        -- api_functions = M.get_registed_api_functions(content)
        api_functions = M.parse_premake_api(content)
        file:close()
    end
    return api_functions, content
end

-- Helper function to split a string by a delimiter
local function split(str, delimiter)
    local result = {}
    local pattern = string.format("([^%s]+)", delimiter)
    for match in string.gmatch(str, pattern) do
        table.insert(result, match)
    end
    return result
end

-- Function to get a specific line from a multi-line string
local function code_range(str, row_start, col_start, row_end, col_end)
    local lines = split(str, "\n")  -- Split the string into lines
    local code = ""
    for i, line in ipairs(lines) do
        if i >= row_start and i <= row_end then
            if row_start == row_end then
                line = line:sub(col_start+1, col_end)
            else
                if i == row_start then
                    line = line:sub(col_start+1, -1)
                end
                if i == row_end then
                    line = line:sub(1, col_end)
                end
            end
            code = code .. line
        end
    end
    return code
end

--- Parse the `_premake_init.lua` file with TreeSitter and extract `premake.api.register` call first arguments.
---@param content string The content of the `_premake_init.lua` file.
---@return table<caleskog.cmp.ApiFunction> table with extracted `premake.api.register` calls.
function M.parse_premake_api(content)
    ---@type table<caleskog.cmp.ApiFunction>
    local api = {}
    -- Test content
    content = [[
        local p = premake
        local api = p.api

        api.register {
            name = "basedir",
            scope = "project",
            kind = "path"
        }
    ]]
    -- Parse the file content using Tree-Sitter
    local parser = vim.treesitter.get_string_parser(content, 'lua')
    local trees = parser:parse()
    if not trees or not trees[1] then
        perror("Failed to parse the file content.")
        return {}
    end

    local root = trees[1]:root()

    -- Query string from file ./queries/api_register.scm
    local filename = vim.fn.stdpath('config') .. '/lua/cmp/api/queries/api_register.scm'
    print('Query file:', filename)
    local file = io.open(filename, 'r')
    if not file then
        perror('Could not open the query file: ' .. filename)
        return {}
    end
    local query = file:read('*a')

    -- Apply the query to the parsed content
    local query_obj = vim.treesitter.query.parse('lua', query)

    -- Traverse the trre and print the tables in api.register calls
    for id, node, _, _ in query_obj:iter_captures(root, content) do
        local capture_name = query_obj.captures[id]
        --[[ if capture_name == 'func_name' then
            -- Print the code around the currect capture.
            local start_row, start_col, end_row, end_col = node:range()
            -- Get the correct line in content string of the capture
            local code = code_range(content, start_row, start_col, end_row, end_col)
            print('Code:', code)
            -- As we are sure we are in the correct function call,
            -- capture the fields: name, scope, and kind.
            local source = code
            local func_node = node:parent():parent():child(2):child(1)
            for id2, node2, _, _ in query_obj:iter_captures(func_node, source) do
                local capture_name2 = query_obj.captures[id2]
                print('Capture name:', capture_name2)
            end
        end ]]
        if capture_name == 'register_func' then
            -- Print the code around the currect capture.
            local start_row, start_col, end_row, end_col = node:range()
            -- Get the correct line in content string of the capture
            local code = code_range(content, start_row, start_col, end_row, end_col)
            print('Code:', code)
            -- As we are sure we are in the correct function call,
            -- capture the fields: name, scope, and kind.
            local source = code
            local details_node = node
            -- print('details_node:', query_obj.capture[details_node:id()])
            for field_id, field_node, _, _ in query_obj:iter_captures(details_node, source) do
                local name = query_obj.captures[field_id]
                print('Capture name:', name)
            end

        end
    end

    print('API functions:', vim.inspect(api))
    return api
end

--- Get all registered API functions.
---Extracting `premake.api.register` calls from `premake-core/src/_premake_init.lua`
---@param content string The content of the `_premake_init.lua` file.
---@return table<caleskog.cmp.ApiFunction> # Table with extracted and parsed `premake.api.register` calls.
function M.get_registed_api_functions(content)
    ---@type table<caleskog.cmp.ApiFunction>
    local api = {}
    -- See this link for fields in the register call: https://github.com/premake/premake-core/blob/master/src/base/api.lua#L239
    local register_pattern = 'api%.register%s*%b{}|api%.register%s*%((.-%)%)' -- Also matches calls without curly brackets
    for api_func in content:gmatch(register_pattern) do
        ---@type caleskog.cmp.ApiFunction
        local api_data = loadstring("return " .. api_func)()
        print('API data:', vim.inspect(api_data))
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
    print('API functions:', vim.inspect(api))
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
    M.initialize()

    local success = M.download_premake_file(repo, path)
    if not success then
        pwarning('Could not download `' .. repo .. '/' .. path .. '` from Github')
    end

    local _, api_functions_str = M.extract_premake_api(M.premake_api)

    M.api_filepath = filename or M.API_DATA .. '/' .. M.PREMAKE_NAME .. '_cmp_source.lua'
    local file = io.open(M.api_filepath, 'w')
    if file then
        file:write('---Generated API file for ' .. M.PREMAKE_NAME .. ' completions\n')
        file:write(api_functions_str)
        file:close()
    end
end

--- Estimate short SHA commit from the installed `premake` binary with the help of the package manager.
--- The function tries to extract the short SHA commit from the output of `dnf info premake`.
--- The function uses a set of patterns to match against the version string.
---@param short_sha string|nil The short SHA commit of the installed `premake` binary.
---@return string short_sha The short SHA commit of the installed `premake` binary.
function M.retrieve_short_sha(short_sha)
    short_sha = short_sha or nil
    if short_sha then
        return short_sha
    end
    local command = 'dnf info premake'
    local premake_version = vim.fn.system(command)
    -- Available version patterns to match against the output of `premake`
    local version_patterns = {
        'Release%s*:%s*[0-9]+%.[0-9]+git([a-z0-9]+)%.fc[0-9]+',
        'Source%s*:%s*premake%-[0-9%.]+%-[0-9]+%.[0-9]+git([a-z0-9]+)%.fc[0-9]+%.src%.rpm',
        'Release%s*:%s*[0-9]+%.[0-9]+git([a-z0-9]+)%.',
    }
    -- Extract the version from the output of `premake5 --help`.
    -- Use the first pattern that matches, testing the patterns in order.
    for _, pattern in ipairs(version_patterns) do
        local sha = premake_version:match(pattern)
        if sha then
            return sha
        end
    end
    error('Could not extract short SHA from `' .. command .. '` string', vim.log.levels.WARN)
end

--- Retrieve the full SHA commit of the installed `premake` binary.
---@param repo string GitHub repository name in the form `username/repo`.
---@param short_sha string The short SHA commit of `premake` to use.
---@return string full_sha The full SHA commit of the installed `premake` binary.
function M.retrieve_full_sha(repo, short_sha)
    local gh_api = 'https://api.github.com/repos/' .. repo .. '/commits/' .. short_sha
    local response_body, code = http.request(gh_api)

    if code ~= 200 then
        error('Failed to get full SHA from GitHub API, HTTP code:' .. code)
    end

    local full_sha = response_body:match('"sha"%s*:%s*"(%w+)"')

    if not full_sha then
        error('Could not retrieve full SHA from GitHub API', vim.log.levels.WARN)
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
    local sha = M.retrieve_full_sha(repo, short_sha)
    local gh_api = string.format('https://raw.githubusercontent.com/%s/%s/%s', repo, sha, path)
    local response_body, code = http.request(gh_api)
    if code ~= 200 then
        error('Failed to download file from GitHub, HTTP code: ' .. code, vim.log.levels.WARN)
        return false
    end
    local converted_content = response_body:gsub("%^I", "\t")
    M.premake_api = M.API_CACHE .. '/' .. M.PREMAKE_NAME .. '_api.lua'
    local file, err = io.open(M.premake_api, "w")
    if not file then
        error('Failed to open file [' .. M.premake_api .. '] for writing: ' .. err)
        return false
    end
    file:write(converted_content)
    file:close()
    return true
end

return M
