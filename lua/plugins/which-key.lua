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
                { '<leader>f', group = 'file/find' },
                { '<leader>s', group = 'search' },
                { '<leader>w', group = 'workspace' },
                { '<leader>c', group = 'code' },
                { '<leader>d', group = 'debugger' },
                { '<leader>g', group = 'git' },
                { '<leader>gh', group = 'hunks' },
                { '<leader>t', group = 'toggle' },
                { '<leader>B', group = 'buffers' },
                -- { '<localleader>l', group = 'LaTeX' }, -- LaTeX specific keymap
                { '<leader>p', group = 'programs' },
                { '<leader>pc', group = 'convert' },
                { '<leader>k', group = 'current document' }, -- filetype specific keymaps
                { 'z', group = 'folds' },
                { 'z=', group = 'spelling suggestions' },
                { '<C-t>', desc = 'jump back (tag)' },
                { '<C-o>', desc = 'jump back (position)' },
                { '<C-i>', desc = 'jump forward (position)' },
                { '[', group = 'prev' },
                { ']', group = 'next' },
                { 'g', group = 'goto' },

                -- Move between windows (ctrl + arrow keys)
                { '<C-Right>', hidden = true },
                { '<C-Down', hidden = true },
                { '<C-Up>', hidden = true },
                { '<C-Left>', hidden = true },
                -- Resize windows (alt + arrow keys)
                { '<A-Right>', hidden = true },
                { '<A-Down', hidden = true },
                { '<A-Up>', hidden = true },
                { '<A-Left>', hidden = true },
                -- Navigation (arrow keys)
                { '<Right>', hidden = true },
                { '<Down', hidden = true },
                { '<Up>', hidden = true },
                { '<Left>', hidden = true },
                -- Move between windows (ctrl + hjkl)
                { '<C-h>', hidden = true },
                { '<C-j>', hidden = true },
                { '<C-k>', hidden = true },
                -- { '<C-l>', hidden = true }, -- This is used to clear search highlights
                -- Resize windows (alt + hjkl)
                { '<A-h>', hidden = true },
                { '<A-j>', hidden = true },
                { '<A-k>', hidden = true },
                { '<A-l>', hidden = true },
                -- Navigation (hjkl)
                { 'h', hidden = true },
                { 'j', hidden = true },
                { 'k', hidden = true },
                { 'l', hidden = true },
                -- Hide common shortcuts
                { 'v', hidden = true },
                { 'V', hidden = true },
                { 'i', hidden = true },
                { '<esc>', hidden = true },
            },
        },
        keys = {
            {
                '<leader>?',
                function()
                    require('which-key').show({ global = false })
                end,
                desc = 'Buffer Keymaps (which-key)',
            },
            -- Hydra mode is when you are allowed to call keymaps sequentially
            -- without re entering the prefix key. In this case, the prefix key
            -- is <c-w>, so you can call multiple keymaps with <c-w> as the prefix.
            {
                '<c-w><space>',
                function()
                    require('which-key').show({ keys = '<c-w>', loop = true })
                end,
                desc = 'Window Hydra Mode (which-key)',
            },
        },
    },
}
