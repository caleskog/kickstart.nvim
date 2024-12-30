-- local l = require('luasnip.extras').lambda
-- l(l.TM_FILENAME) -- returns the filename

return {
    s({
        trig = '--ca',
        name = 'File-Header',
        desc = 'File information',
    }, {
        c(1, {
            t({ '-- Copyright (c) 2024 caleskog. All Rights Reserved.' }),
            t({ '---@author caleskog ' }),
        }),
        ---@diagnostic disable-next-line: unused-local
        f(function(args, parent, user_args)
            local handle = io.popen('git config user.email')
            if not handle then
                return ''
            end
            local email = handle:read('*a')
            handle:close()
            email = email:gsub('\n', '')
            return { '(' .. email .. ')', '' }
        end, {}),
        f(function(_, snip)
            local filename = snip.env.TM_FILENAME
            local path = snip.env.TM_DIRECTORY
            local project_root = vim.fn.getcwd()
            path = path:gsub(project_root, ''):gsub('^/', '')
            return '---@file ' .. path .. '/' .. filename
        end, {}),
        t({ '', '---@description ' }),
        i(2, 'description'),
    }),
}
