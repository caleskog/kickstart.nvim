---@author caleskog
---@description Completion API for nvim-cmp regarding premake5.
---@version 0.0.1

local common = require('cmp.api.premake.common')
local extractor = require('cmp.api.premake.extractor')
local http = require('socket.http')

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

--- Parse the provided lua file containing the `premake.api.register` calls. Retrive the necessary information from the registered API functions.
---@param path string Path to the `_premake_init.lua` file.
---@param repo string GitHub repository name in the form `username/repo`.
---@return table table with extracted `premake.api.register` calls.
---@return string string The content of the `_premake_init.lua` file.
---@usage local api = extract_premake_api('path/to/_premake_init.lua')
function M.extract_premake_api(path, repo)
    local content = ''
    local api_functions = {}
    local file = io.open(path, 'r')
    if file then
        ---@type string
        content = file:read('*a')
        -- Retrive the SHA commit from the file content
        local sha = content:match('^#%[INJECTED AUTOMATICALLY%]%s+SHA=(%w+)')
        -- convert ^I to tabs
        content = content:gsub('%^I', '\t')
        -- api_functions = M.get_registed_api_functions(content)
        api_functions = M.parse_premake_api(content, repo, sha)
        file:close()
    end
    return api_functions, content
end

-- Function to get a specific line from a multi-line string
local function code_range(str, row_start, col_start, row_end, col_end)
    local lines = common.split(str, '\n') -- Split the string into lines
    local code = ''
    for i, line in ipairs(lines) do
        if i >= row_start and i <= row_end then
            if row_start == row_end then
                line = line:sub(col_start + 1, col_end)
            else
                if i == row_start then
                    line = line:sub(col_start + 1, -1)
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
---@param repo string GitHub repository name in the form `username/repo`.
---@param commit_sha string The SHA commit of the `premake` binary used for retriveing the premake api functions.
---@return table<caleskog.cmp.ApiFunction> table with extracted `premake.api.register` calls.
function M.parse_premake_api(content, repo, commit_sha)
    ---@type table<caleskog.cmp.ApiFunction>
    local api = {}

    -- Set test content for testing purposes
    content = common.TEST_CONTENT

    -- Parse the file content using Tree-Sitter
    local parser = vim.treesitter.get_string_parser(content, 'lua')
    local trees = parser:parse()
    if not trees or not trees[1] then
        gperror('Failed to parse the file content.')
        return {}
    end

    local root = trees[1]:root()

    -- Query string from file ./queries/api_register.scm
    local filename = vim.fn.stdpath('config') .. '/lua/cmp/api/queries/api_register.scm'
    local file = io.open(filename, 'r')
    if not file then
        gperror('Could not open the query file: ' .. filename)
        return {}
    end
    local query = file:read('*a')

    -- Apply the query to the parsed content
    local query_obj = vim.treesitter.query.parse('lua', query)

    -- Traverse the trre and print the tables in api.register calls
    for id, node, _, _ in query_obj:iter_captures(root, content) do
        local capture_name = query_obj.captures[id]
        if capture_name == 'register_func' then
            -- Print the code around the currect capture.
            local start_row, start_col, end_row, end_col = node:range()
            -- Get the correct line in content string of the capture
            local code = code_range(content, start_row, start_col, end_row, end_col)
            -- print('Code:', code)
            -- As we are sure we are in the correct function call,
            -- capture the fields: name, scope, and kind.
            for field_id, field_node, _, _ in query_obj:iter_captures(node, content) do
                local inner_capture_name = query_obj.captures[field_id]
                local allowed_fields = { 'name', 'scope', 'kind', 'allowed', 'aliases', 'pathVars', 'tokens', 'allowDuplicates' }
                if vim.tbl_contains(allowed_fields, inner_capture_name) then
                    ---@type table<caleskog.premake5.ApiField>
                    local field = extractor.capture_register_fields(query_obj, inner_capture_name, field_node, content, repo, commit_sha)
                    -- if inner_capture_name == 'allowed' then
                    --     gpdebug(inner_capture_name .. ':', field)
                    -- end
                end
                -- p(scope, 'scope')
            end
        elseif capture_name == 'alias_func' then
            local alias_original = ''
            local alias_new = {}
            for _, match, _ in query_obj:iter_matches(node, content, 0, -1, { all = true }) do
                for alias_id, nodes in pairs(match) do
                    local alias_capture_name = query_obj.captures[alias_id]
                    if alias_capture_name == 'alias_string' then
                        for _, alias_node in ipairs(nodes) do
                            local inner_tbl = extractor.capture_string(alias_node, content)
                            -- The first parameter is the original
                            if alias_original == '' then
                                alias_original = inner_tbl.text
                            else
                                table.insert(alias_new, inner_tbl)
                            end
                        end
                    end
                end
            end
            local aliases = {
                original = alias_original,
                aliases = alias_new,
            }
            gpdebug('Aliases:', aliases)
        end
    end

    -- print('API functions:', vim.inspect(api))
    return api
end

--- TODO: Not used, can be removed.
---
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
        local api_data = loadstring('return ' .. api_func)()
        print('API data:', vim.inspect(api_data))
        if api_data.name then
            -- As I don't have the `premake-core` source code, it's not possilbe to parse the allowed fields if they are functions.
            if type(api_data.allowed) == 'function' then
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
        gpwarning('Could not download `' .. repo .. '/' .. path .. '` from Github')
    end

    local api_functions, api_file_content = M.extract_premake_api(M.premake_api, repo)

    M.api_filepath = filename or M.API_DATA .. '/' .. M.PREMAKE_NAME .. '_cmp_source.lua'
    local file = io.open(M.api_filepath, 'w')
    if file then
        file:write('---Generated API file for ' .. M.PREMAKE_NAME .. ' completions\n')
        file:write(api_file_content)
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
    local converted_content = response_body:gsub('%^I', '\t')
    M.premake_api = M.API_CACHE .. '/' .. M.PREMAKE_NAME .. '_api.lua'
    local file, err = io.open(M.premake_api, 'w')
    if not file then
        error('Failed to open file [' .. M.premake_api .. '] for writing: ' .. err)
        return false
    end
    file:write("#[INJECTED AUTOMATICALLY] SHA=" .. sha .. "\n")
    file:write(converted_content)
    file:close()
    return true
end

--- Testing purposes only
--- TODO: Remove this when the function is no longer needed.
--- NOTE: :lua vim.keymap.set('n', '<leader>,,', ':luafile ./lua/cmp/api/premake/premake5.lua<cr>', { silent=true, noremap=true})
M.parse_premake_api('premake5_api_completions.lua', 'premake/premake-core', '9c9b6fc4ca1937ce2ec2e40621a9bb273306906d')

return M
