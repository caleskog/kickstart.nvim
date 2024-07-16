-- File: plugins/which-key.lua
-- Author: caleskog
-- Description: For helping the user with which key to use.

return {
    { -- Useful plugin to show you pending keybinds.
        'folke/which-key.nvim',
        event = 'VeryLazy', -- Sets the loading event to 'VimEnter'
        opts = {
            spec = {
                { '<leader>f', group = '[F]find' },
                -- { '<leader>w', group = '[W]orkspace'},
                { '<leader>d', group = '[D]ebugger' },
                { '<leader>g', group = '[G]it' },
                { '<leader>p', group = '[P]rograms' },
                { '<leader>pm', group = '[M]arkdown' },
                { 's', group = '[S]urround' },
                { 'z', group = 'View, Folds, Misc.' },
                { 'z=', group = 'Spelling suggestions' },
            },
        },
        keys = {},
    },
}
