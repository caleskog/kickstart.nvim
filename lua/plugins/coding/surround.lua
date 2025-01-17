-- Author: caleskog

-- Fast and feature-rich surround actions. For text that includes
-- surrounding characters like brackets or quotes, this allows you
-- to select the text inside, change or modify the surrounding characters,
-- and more.
return {
    {
        'echasnovski/mini.surround',
        -- version = '*',
        recommended = true,
        keys = function(_, keys)
            -- Populate the keys based on the user's options
            local opts = Core.opts('mini.surround')
            local mappings = {
                { opts.mappings.add, desc = 'Add Surrounding', mode = { 'n', 'v' } },
                { opts.mappings.delete, desc = 'Delete Surrounding' },
                -- { opts.mappings.find, desc = 'Find Right Surrounding' },
                -- { opts.mappings.find_left, desc = 'Find Left Surrounding' },
                -- { opts.mappings.highlight, desc = 'Highlight Surrounding' },
                { opts.mappings.replace, desc = 'Replace Surrounding' },
                -- { opts.mappings.update_n_lines, desc = 'Update `MiniSurround.config.n_lines`' },
                { 'gs', '', desc = '+surround' },
            }
            mappings = vim.tbl_filter(function(m)
                return m[1] and #m[1] > 0
            end, mappings)
            return vim.list_extend(mappings, keys)
        end,
        opts = {
            mappings = {
                add = 'gsa', -- Add surrounding in Normal and Visual modes
                delete = 'gsd', -- Delete surrounding
                find = '', -- Find surrounding (to the right)
                find_left = '', -- Find surrounding (to the left)
                highlight = '', -- Highlight surrounding
                replace = 'gsr', -- Replace surrounding
                update_n_lines = '', -- Update `n_lines`
            },
        },
    },
}
