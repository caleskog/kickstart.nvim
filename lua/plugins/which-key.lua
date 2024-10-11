-- File: plugins/which-key.lua
-- Author: caleskog
-- Description: For helping the user with which key to use.

return {
    { -- Useful plugin to show you pending keybinds.
        'folke/which-key.nvim',
        event = 'VeryLazy', -- Sets the loading event to 'VimEnter'
        opts = {
            preset = 'modern',
            spec = {
                { '<leader>f', group = 'Find' },
                { '<leader>w', group = 'Workspace' },
                { '<leader>c', group = 'Code' },
                { '<leader>d', group = 'Debugger' },
                { '<leader>g', group = 'Git' },
                { '<leader>p', group = 'Programs' },
                { '<localleader>l', group = 'LaTeX' },
                { '<leader>pm', group = 'Markdown' },
                { '<leader>pc', group = 'Convert' },
                { '<leader>s', group = 'Surround' },
                { 'z', group = 'View, Folds, Misc.' },
                { 'z=', group = 'Spelling suggestions' },
                { '<C-t>', desc = 'Jump back (tag)' },
                { '<C-o>', desc = 'Jump back (position)' },

                -- Hide common shortcuts
                { '<C-h>', hidden = true },
                { '<C-j>', hidden = true },
                { '<C-k>', hidden = true },
                { '<C-l>', hidden = true },
                { '<A-h>', hidden = true },
                { '<A-j>', hidden = true },
                { '<A-k>', hidden = true },
                { '<A-l>', hidden = true },
                { 'h', hidden = true },
                { 'j', hidden = true },
                { 'k', hidden = true },
                { 'l', hidden = true },
                { 'v', hidden = true },
                { 'V', hidden = true },
                { 'i', hidden = true },
                { '<esc>', hidden = true },
            },
        },
    },
}
