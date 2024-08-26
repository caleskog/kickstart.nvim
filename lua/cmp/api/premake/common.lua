---@author caleskog
---@description Types and global functions for completion API regarding Premake5.

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

---@class caleskog.premake5.ApiField
---@field text string The text of the field.
---@field type string The type of the field. Can be 'string', 'identifier', 'function', 'boolean', etc.
---@field origin string The origin of the field. Can be 'local', 'static', 'premake', etc.
---@field source? table<string> The source of the field. Can be a URL to the source code.
---@field key? string The key of the field. Only used in tables.
---@field values? table<caleskog.premake5.ApiField> The values of the field. Only used in tables.
---@field function_definition? string The full function definition. Only used for functions.

local M = {}

-- Helper function to split a string by a delimiter
function M.split(str, delimiter)
    local result = {}
    local pattern = string.format('([^%s]+)', delimiter)
    for match in string.gmatch(str, pattern) do
        table.insert(result, match)
    end
    return result
end

--- Helper function to print a TSNode
function M.ptsn(node, source)
    gprint(vim.treesitter.get_node_text(node, source))
end

--- Test content
M.TEST_CONTENT = [[

        local p = premake
        local api = p.api

        api.register {
            name = "basedir",
            scope = "project",
            kind = "path"
        }

        api.register {
            name = "filename",
            scope = { "project", "rule" },
            kind = "string",
            pathVars = true,
            tokens = true,
            allowDuplicates = true,
        }

        api.register {
            name = "flags",
            scope = "config",
            kind  = "list:string",
            allowed = {
                "Component",           -- DEPRECATED
                "DebugEnvsDontMerge",
                "EnableSSE",           -- DEPRECATED
                "EnableSSE2",          -- DEPRECATED
                "FatalCompileWarnings",
                "FatalLinkWarnings",
                "Optimize",            -- DEPRECATED
                "OptimizeSize",        -- DEPRECATED
                'C++11', -- DEPRECATED
                'C++14', -- DEPRECATED
                p.X86,
                p.X86_64,
                myArch,
            },
            aliases = {
                FatalWarnings = { "FatalWarnings", "FatalCompileWarnings", "FatalLinkWarnings" },
                Optimise = 'Optimize',
                OptimiseSize = 'OptimizeSize',
                x64 = p.x86_64,
            },
        }

        api.register {
            name = "uuid",
            scope = "project",
            kind = "string",
            allowed = function(value)
                local ok = true
                if (#value ~= 36) then ok = false end
                for i=1,36 do
                    local ch = value:sub(i,i)
                    if (not ch:find("[ABCDEFabcdef0123456789-]")) then ok = false end
                end
                if (value:sub(9,9) ~= "-")   then ok = false end
                if (value:sub(14,14) ~= "-") then ok = false end
                if (value:sub(19,19) ~= "-") then ok = false end
                if (value:sub(24,24) ~= "-") then ok = false end
                if (not ok) then
                    return nil, "invalid UUID"
                end
                return value:upper()
            end
        }

        api.register({
            name = 'buildaction',
            scope = 'config',
            kind = 'string',
        })

        api.register {
            name = "buildcommands",
            scope = { "config", "rule" },
            kind = "list:string",
            tokens = true,
            pathVars = true,
        }

        api.register({
            name = 'buildmessage',
            scope = { 'config', 'rule' },
            kind = 'string',
            tokens = true,
            pathVars = true,
        })

        api.register({
            name = 'buildoutputs',
            scope = { 'config', 'rule' },
            kind = 'list:path',
            tokens = true,
            pathVars = false,
        })

        api.register({
            name = 'cppdialect',
            scope = 'config',
            kind = 'string',
            allowed = {
                'Default',
                'C++latest',
                'C++98',
                'C++0x',
                'C++11',
                'C++1y',
                'C++14',
                'C++1z',
                'C++17',
                'C++2a',
                'C++20',
                'gnu++98',
                'gnu++0x',
                'gnu++11',
                'gnu++1y',
                'gnu++14',
                'gnu++1z',
                'gnu++17',
                'gnu++2a',
                'gnu++20',
            },
        })

        api.register({
            name = 'symbols',
            scope = 'config',
            kind = 'string',
            allowed = {
                'Default',
                'On',
                'Off',
                'FastLink', -- Visual Studio 2015+ only, considered 'On' for all other cases.
                'Full', -- Visual Studio 2017+ only, considered 'On' for all other cases.
            },
        })

        api.register({
            name = 'vectorextensions',
            scope = 'config',
            kind = 'string',
            allowed = {
                'Default',
                'AVX',
                'AVX2',
                'IA32',
                'SSE',
                'SSE2',
                'SSE3',
                'SSSE3',
                'SSE4.1',
                'SSE4.2',
            },
        })

        api.register({
            name = 'buildrule', -- DEPRECATED
            scope = 'config',
            kind = 'table',
            tokens = true,
        })

        api.alias("buildcommands", "buildCommands")
        -- api.alias("dotnetframework", "framework", "dotnet")

        api.deprecateField('buildrule', 'Use `buildcommands`, `buildoutputs`, and `buildmessage` instead.', function(value)
            if value.description then
                buildmessage(value.description)
            end
            buildcommands(value.commands)
            buildoutputs(value.outputs)
        end)

        api.deprecateValue('flags', 'Component', 'Use `buildaction "Component"` instead.', function(value)
            buildaction('Component')
        end)

        api.deprecateValue('flags', 'EnableSSE', 'Use `vectorextensions "SSE"` instead.', function(value)
            vectorextensions('SSE')
        end, function(value)
            vectorextensions('Default')
        end)

        api.deprecateValue('flags', 'EnableSSE2', 'Use `vectorextensions "SSE2"` instead.', function(value)
            vectorextensions('SSE2')
        end, function(value)
            vectorextensions('Default')
        end)

        api.deprecateValue('flags', 'Symbols', 'Use `symbols "On"` instead', function(value)
            symbols('On')
        end, function(value)
            symbols('Default')
        end)

        api.deprecateValue('flags', 'C++11', 'Use `cppdialect "C++11"` instead', function(value)
            cppdialect('C++11')
        end, function(value)
            cppdialect('Default')
        end)

        api.deprecateValue('flags', 'C++14', 'Use `cppdialect "C++14"` instead', function(value)
            cppdialect('C++14')
        end, function(value)
            cppdialect('Default')
        end)
    ]]

return M
