-- Fike: plugins/init.lua
-- Author: caleskog
-- Description: Miscellaneous plugins that doen't require much configuration.

-- Load the core configuration first
Core.config.init({
    notifier = 'snacks',
})

return {
    { -- "gc" to comment visual regions/lines
        'numToStr/Comment.nvim',
        event = 'VeryLazy',
        opts = {},
    },

    {
        -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
        'folke/tokyonight.nvim',
        priority = 10000, -- Make sure to load this before all the other start plugins.
        init = function()
            -- vim.cmd.colorscheme('tokyonight-night')
            vim.cmd.colorscheme('tokyonight')

            -- You can configure highlights by doing something like:
            -- vim.cmd.hi('Comment gui=none')
        end,
    },

    {
        'folke/snacks.nvim',
        priority = 1000,
        lazy = false,
        ---@module 'snacks'
        ---@type snacks.Config
        opts = {
            toggle = {
                enabled = true,
            },
        },
        config = function(_, opts)
            local notify = vim.notify
            require('snacks').setup(opts)
            -- HACK: restore vim.notify after snacks setup and let noice.nvim take over
            -- this is needed to have early notifications show up in noice history
            if Core.has('noice.nvim') then
                vim.notify = notify
            end
        end,
        -- stylua: ignore
        keys = {
            { '<leader>un', function() Snacks.notifier.hide() end, desc = 'Hide notifications' },
        },
    },

    -- Highlight todo, notes, etc in comments
    {
        'folke/todo-comments.nvim',
        cmd = { 'TodoTelescope' },
        event = 'LazyFile',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope.nvim',
        },
        opts = {
            signs = false,
            -- stylua: ignore
            keywords = {
                INPORTANT = { icon = '', color = '#ff0000', alt = { 'IMPORTANT', 'CRIT', 'CRITICAL' } },
                FIX = { icon = '', color = '#b2182b', alt = { 'FIXME', 'BUG', 'FIX' } },
                WARN = { icon = '', color = '#fee08b', alt = { 'WARNING', 'CAUTION' } },
                HACK = { icon = '󰶯', color = '#ef8a62' },
                PERFORMACE = { icon = '󰅒', color = '#af8dc3', alt = { 'PERF', 'PERFORMANCE', 'OPTIM' } },
                TODO = { icon = '', color = '#2166ac', alt = { 'TODO' } },
                NOTE = { icon = '', color = '#458588', alt = { 'NOTE', 'INFO' } },
                HELP = { icon = '󰞋', color = '#1b7837', alt = { 'HELP' } },
            },
            merge_keywords = true,
        },
        -- stylua: ignore
        keys = {
            { ']t', function() require('todo-comments').jump_next() end, desc = 'Next Todo Comment' },
            { '[t', function() require('todo-comments').jump_prev() end, desc = 'Previous Todo Comment' },
            -- Using Telescope
            { '<leader>st', '<cmd>TodoTelescope<cr>', desc = 'Todo' },
            { '<leader>sT', '<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>', desc = 'Todo/Fix/Fixme' },
        },
    },

    {
        'mbbill/undotree',
        event = 'VeryLazy',
        config = function()
            Core.utils.keymap.cmap('n', '<leader>su', 'Telescope undo', 'UndoList')
        end,
    },
}
