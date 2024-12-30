-- Copyright (c) 2024 caleskog. All Rights Reserved.
---@author caleskog (christoffer.aleskog@gmail.com)
---@file luasnippets/lua/doc.lua
---@description Snippets for generating documentation comments

local fmt = require('luasnip.extras.fmt').fmt

---Get the git config value for the given key
---@param key string
local function gitv(key)
    if not key then
        error('key is required')
    end
    local file = io.popen('git config ' .. key)
    if not file then
        error('Could not open file')
    end
    local ret = file:read('*a'):gsub('\n', '')
    file:close()
    return ret
end

---Retrieve current file path relative to the project root
---@return string
local function filepath(env)
    local path = env.TM_FILEPATH
    local project_root = vim.fn.getcwd()
    path = path:gsub(project_root, ''):gsub('^/', '')
    return path
end

return {
    s(
        {
            trig = 'ctop',
            name = 'File-Header',
            desc = 'File information',
        },
        fmt(
            [[
        -- Copyright (c) 2024 {author}. All Rights Reserved.
        ---@author {author} ({email})
        ---@file {file}
        ---@description {desc}
        ]],
            {
                author = t(gitv('user.name')),
                email = t(gitv('user.email')),
                file = f(function(_, parent)
                    return filepath(parent.env)
                end, {}),
                desc = i(1, 'description'),
            }
        )
    ),
}