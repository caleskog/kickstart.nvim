-- Author: caleskog

return {
    {
        'echasnovski/mini.surround',
        version = '*',
        opts = {
            mappings = {
                add = 'gsa',
                delete = 'gsd',
                find = 'gsf',
                find_left = 'gsF',
                highlight = 'gsh',
                replace = 'gsr',
                update = 'gsu',
                suffix_last = 'gs,',
                suffix_next = 'gs;',
            },
        },
        config = function(opts)
            -- Add/delete/replace surroundings (brackets, quotes, etc.)
            --
            -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
            -- - sd'   - [S]urround [D]elete [']quotes
            -- - sr)'  - [S]urround [R]eplace [)] [']
            require('mini.surround').setup({ opts })
        end,
        keys = {
            { 'gs', '', desc = '+surround' },
        },
    },
}
