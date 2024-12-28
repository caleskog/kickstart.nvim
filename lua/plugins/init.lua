-- Fike: plugins/init.lua
-- Author: caleskog
-- Description: Miscellaneous plugins that doen't require much configuration.

-- Load the core configuration first
Core.config.init()

return {
    -- Use `opts = {}` to force a plugin to be loaded.
    --
    --  This is equivalent to:
    --    require('Comment').setup({})

    { -- "gc" to comment visual regions/lines
        'numToStr/Comment.nvim',
        event = 'VeryLazy',
        opts = {},
    },

    -- {
    --     'EdenEast/nightfox.nvim',
    --     priority = 1000,
    --     init = function()
    --         vim.cmd.colorscheme('nightfox')
    --     end,
    --     opt = true,
    -- },
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
            notifier = {
                enabled = true, -- FIX: This is not working. Change to nvim-notify or try to fix
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
    },

    -- Highlight todo, notes, etc in comments
    {
        -- NOTE: adding a note
        -- TODO: What else?
        -- INPORTANT: This is really important
        -- FIX: this needs fixing
        -- WARNING: be careful, it might break
        -- HACK: hmm, this looks a bit funky
        -- PERF: fully optimised
        -- HELP: Some kind of helpfull message

        'folke/todo-comments.nvim',
        event = 'VimEnter',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope.nvim',
        },
        opts = {
            signs = false,
            keywords = {
                INPORTANT = {
                    icon = '',
                    color = '#ff0000',
                    alt = { 'IMPORTANT', 'CRIT', 'CRITICAL' },
                },
                FIX = {
                    icon = '',
                    color = '#b2182b',
                    alt = { 'FIXME', 'BUG', 'FIX' },
                },
                WARN = {
                    icon = '',
                    color = '#fee08b',
                    alt = { 'WARNING', 'CAUTION' },
                },
                HACK = {
                    icon = '󰶯',
                    color = '#ef8a62',
                },
                PERFORMACE = {
                    icon = '󰅒',
                    color = '#af8dc3',
                    alt = { 'PERF', 'PERFORMANCE', 'OPTIM' },
                },
                TODO = {
                    icon = '',
                    color = '#2166ac',
                    alt = { 'TODO' },
                },
                NOTE = {
                    icon = '',
                    color = '#458588',
                    alt = { 'NOTE', 'INFO' },
                },
                HELP = {
                    icon = '󰞋',
                    color = '#1b7837',
                    alt = { 'HELP' },
                },
            },
            merge_keywords = true,
        },
        keys = {
            { '<leader>ft', '<cmd>TodoTelescope<cr>', desc = 'TodotList' }, -- Using Telescope
        },
    },

    {
        'mbbill/undotree',
        event = 'VeryLazy',
        -- dependencies = {
        --     'rcarriga/nvim-notify',
        -- },
        config = function()
            Core.utils.keymap.cmap('n', '<leader>fu', 'Telescope undo', 'UndoList')
        end,
    },
}
