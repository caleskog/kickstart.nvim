-- Author: caleskog

return {
    {
        'echasnovski/mini.surround',
        version = '*',
        opts = {
            mappings = {
                add = 'sa',
                delete = 'sd',
                find = 'sf',
                find_left = 'sF',
                highlight = 'sh',
                replace = 'sr',
                update = 'su',
                suffix_last = 's,',
                suffix_next = 's;',
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
    },
}
