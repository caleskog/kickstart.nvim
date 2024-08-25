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

        api.register {
            name = "buildcommands",
            scope = { "config", "rule" },
            kind = "list:string",
            tokens = true,
            pathVars = true,
        }

        api.alias("buildcommands", "buildCommands")
        api.alias("dotnetframework", "framework", "dotnet")
    ]]

return M
