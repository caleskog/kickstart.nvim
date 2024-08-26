---@author caleskog
---@description Extractor API for Premake5 global functions.

local M = {}

---@param root TSNode the captured node
---@param content string The content of the file
---@return caleskog.premake5.ApiField
function M.capture_string(root, content)
    local string_content = root:named_child(0)
    ---@diagnostic disable-next-line: param-type-mismatch
    local field_text = vim.treesitter.get_node_text(string_content, content)
    -- gprint('Field string:', node_text)
    ---@type caleskog.premake5.ApiField
    local api_field = {
        text = field_text,
        type = 'string',
        origin = 'static',
    }
    return api_field
end

---@param root TSNode the captured node
---@param content string The content of the file
---@return caleskog.premake5.ApiField
function M.capture_identifier(root, content)
    local identifier_name = vim.treesitter.get_node_text(root, content)
    ---@type caleskog.premake5.ApiField
    local api_field = {
        text = identifier_name,
        type = 'identifier',
        origin = 'local',
    }
    return api_field
end

---@param root TSNode the captured node
---@param content string The content of the file
---@return caleskog.premake5.ApiField
function M.capture_dotted_index_expression(root, content, repo, commit_sha)
    ---@diagnostic disable-next-line: param-type-mismatch
    local dotted_id_name = vim.treesitter.get_node_text(root:named_child(0), content)
    if dotted_id_name == 'p' then
        dotted_id_name = 'premake'
    end
    ---@diagnostic disable-next-line: param-type-mismatch
    local identifier_name = vim.treesitter.get_node_text(root:named_child(1), content)
    local api_field = {
        source = {
            'https://github.com/' .. repo .. '/blob/' .. commit_sha .. '/src/base/_foundation.lua#L26',
        },
        text = identifier_name,
        type = 'identifier',
        origin = dotted_id_name,
    }
    return api_field
end

---@param root TSNode the captured node
---@param content string The content of the file
---@return caleskog.premake5.ApiField
function M.capture_function_definition(root, content)
    -- Get the full function footprint without the body
    local function_footprint = ''
    ---@diagnostic disable-next-line: param-type-mismatch
    local function_start = vim.treesitter.get_node_text(root:child(0), content)
    ---@diagnostic disable-next-line: param-type-mismatch
    local parametr_list = vim.treesitter.get_node_text(root:named_child(0), content)
    ---@diagnostic disable-next-line: param-type-mismatch
    local function_end = vim.treesitter.get_node_text(root:child(3), content)
    function_footprint = function_start .. parametr_list .. ' ... ' .. function_end

    local function_definition = vim.treesitter.get_node_text(root, content)
    ---@type caleskog.premake5.ApiField
    local api_field = {
        text = function_footprint,
        source = {
            function_definition,
        },
        type = 'function',
        origin = 'local',
    }
    return api_field
end

---Cehck and return a capture field
---@param query vim.treesitter.Query
---@param node TSNode the captured node
---@param content string The content of the file
---@param repo string GitHub repository name in the form `username/repo`.
---@param commit_sha string The SHA commit of the `premake` binary used for retriveing the premake api functions.
---@return table<caleskog.premake5.ApiField>
function M.capture_register_fields(query, name, node, content, repo, commit_sha)
    if node:type() == 'string_content' then
        local node_text = vim.treesitter.get_node_text(node, content)
        ---@type caleskog.premake5.ApiField
        local api_field = {
            text = node_text,
            type = 'string',
            origin = 'static',
        }
        return api_field
    elseif node:type() == 'table_constructor' then
        -- Make a table of strings from the node
        ---@type table<caleskog.premake5.ApiField>
        local tbl = {}
        -- local param_opts = { '2', { rule = '<' } }
        -- gprint('Content:', '\n' .. content, { param_opts = param_opts })
        for _, top_match, _ in query:iter_matches(node, content, 0, -1, { all = true }) do
            local field_node = nil
            for id, nodes in pairs(top_match) do
                local capture_name = query.captures[id]
                if capture_name == 'premake_field' then
                    field_node = nodes[1]
                    break
                end
            end
            if field_node then
                -- ptsn(field_node, content)
                for _, match, _ in query:iter_matches(field_node, content, 0, -1, { all = true }) do
                    if name == 'aliases' then
                        -- For checking if the field inclusion is @field_name
                        for id, nodes in pairs(match) do
                            local capture_name = query.captures[id]
                            local root = nodes[1]
                            -- gpdebug('Capture name:', capture_name)
                            -- ptsn(root, content)
                            if capture_name == 'field_name' then
                                -- ptsn(nodes[1]:parent():named_child(0), content)
                                -- ptsn(nodes[1]:parent():named_child(1), content)
                                -- p(nodes[1]:parent():named_child(1):type(), 'Field name')
                                local lhs_node = root:parent():named_child(0)
                                ---@diagnostic disable-next-line: param-type-mismatch
                                local lhs_text = vim.treesitter.get_node_text(lhs_node, content)
                                ---@type table<caleskog.premake5.ApiField>
                                local rhs_fields = {}
                                for rhs_id, rhs_nodes in pairs(match) do
                                    local rhs_capture_name = query.captures[rhs_id]
                                    local rhs_root = rhs_nodes[1]
                                    if rhs_capture_name == 'field_string' then
                                        local inner_tbl = M.capture_string(rhs_root, content)
                                        table.insert(rhs_fields, inner_tbl)
                                    elseif rhs_capture_name == 'field_identifier' then
                                        local inner_tbl = M.capture_identifier(rhs_root, content)
                                        table.insert(rhs_fields, inner_tbl)
                                    elseif rhs_capture_name == 'field_dotted_expression' then
                                        local inner_tbl = M.capture_dotted_index_expression(rhs_root, content, repo, commit_sha)
                                        table.insert(rhs_fields, inner_tbl)
                                    elseif rhs_capture_name == 'field_table' then
                                        ---@diagnostic disable-next-line: cast-local-type
                                        rhs_fields = M.capture_register_fields(query, '', rhs_root, content, repo, commit_sha)
                                    end
                                end
                                table.insert(tbl, {
                                    key = lhs_text,
                                    values = rhs_fields,
                                })
                                break -- Exit early once we find `@field_name`
                            end
                        end
                    else
                        for id, nodes in pairs(match) do
                            local capture_name = query.captures[id]
                            local root = nodes[1]

                            if capture_name == 'field_string' then
                                local inner_tbl = M.capture_string(root, content)
                                table.insert(tbl, inner_tbl)
                            elseif capture_name == 'field_identifier' then
                                local inner_tbl = M.capture_identifier(root, content)
                                table.insert(tbl, inner_tbl)
                            elseif capture_name == 'field_dotted_expression' then
                                local inner_tbl = M.capture_dotted_index_expression(root, content, repo, commit_sha)
                                table.insert(tbl, inner_tbl)
                            end
                        end
                    end
                end
            end
        end
        return tbl
    elseif node:type() == 'identifier' then
        local parent = node:parent()
        ---@diagnostic disable-next-line: need-check-nil
        local value_node = parent:child(2)
        if not value_node then
            return {
                text = 'nil',
                type = 'nil',
                origin = 'static',
            }
        end
        -- Ckeck if the value filed of the identifier is a false or true (indicating a boolean value)
        if value_node:type() == 'true' then
            ---@type caleskog.premake5.ApiField
            local api_field = {
                text = 'true',
                type = 'boolean',
                origin = 'static',
            }
            return api_field
        end
        if value_node:type() == 'false' then
            ---@type caleskog.premake5.ApiField
            local api_field = {
                text = 'false',
                type = 'boolean',
                origin = 'static',
            }
            return api_field
        end
        return M.capture_identifier(node, content)
    elseif node:type() == 'function_definition' then
        ---@type caleskog.premake5.ApiField
        local api_field = M.capture_function_definition(node, content)
        return api_field
    end
    return {
        text = 'nil',
        type = 'nil',
        origin = 'static',
    }
end

return M
