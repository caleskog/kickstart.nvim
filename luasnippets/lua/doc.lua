-- local l = require('luasnip.extras').lambda
-- l(l.TM_FILENAME) -- returns the filename

return {
    s({
        trig = '--ca',
        name = 'File header',
        desc = 'Author and file information',
    }, {
        t({ '---@author caleskog ' }),
        f(function(_, _)
            local handle = io.popen('git config user.email')
            if not handle then
                return ''
            end
            local email = handle:read('*a')
            handle:close()
            return '(' .. email:gsub('\n', '') .. ')\n'
        end, {}),
        f(function(_, snip)
            local filename = snip.env.TM_FILENAME
            local path = snip.env.TM_DIRECTORY
            local project_root = vim.fn.getcwd()
            path = path:gsub(project_root, ''):gsub('^/', '')
            return '---@file ' .. path .. '/' .. filename
        end, {}),
        t({ '', '---@description ' }),
        i(1, 'description'),
    }),
}
