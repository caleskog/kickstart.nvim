-- File: plugins/which-key.lua
-- Author: caleskog
-- Description: For helping the user with which key to use.

return {
    { -- Useful plugin to show you pending keybinds.
        'folke/which-key.nvim',
        event = 'VimEnter', -- Sets the loading event to 'VimEnter'
        config = function() -- This is the function that runs, AFTER loading
            vim.o.timeout = true
            vim.o.timeoutlen = 500
            require('which-key').setup()

            -- Document existing key chains
            -- TODO: Updated Which-Key mappings
            require('which-key').register({
                -- ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
                -- ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
                -- ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
                ['<leader>f'] = { name = '[F]find', _ = 'which_key_ignore' },
                -- ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
                ['<leader>d'] = { name = '[D]ebugger', _ = 'which_key_ignore' },
                ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
                ['<leader>p'] = { name = '[P]rograms', _ = 'which_key_ignore' },
                ['<leader>pm'] = { name = '[M]arkdown', _ = 'which_key_ignore' },
                ['s'] = { name = '[S]urround', _ = 'which_key_ignore' },
                ['z'] = { name = 'View, Folds, Misc.', _ = 'which_key_ignore' },
                ['z='] = { name = 'Spelling suggestions', _ = 'which_key_ignore' },
            })
        end,
    },
}
