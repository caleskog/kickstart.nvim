-- Fike: plugins/init.lua
-- Author: caleskog
-- Description: Miscellaneous plugins that doen't require much configuration.

return {
    'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

    -- Use `opts = {}` to force a plugin to be loaded.
    --
    --  This is equivalent to:
    --    require('Comment').setup({})

    { -- "gc" to comment visual regions/lines
        'numToStr/Comment.nvim',
        opts = {},
    },

    -- Here is a more advanced example where we pass configuration
    -- options to `gitsigns.nvim`. This is equivalent to the following Lua:
    --    require('gitsigns').setup({ ... })
    --
    -- See `:help gitsigns` to understand what the configuration keys do
    { -- Adds git related signs to the gutter, as well as utilities for managing changes
        'lewis6991/gitsigns.nvim',
        opts = {
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
            },
        },
    },

    {
        -- You can easily change to a different colorscheme.
        -- Change the name of the colorscheme plugin below, and then
        -- change the command in the config to whatever the name of that colorscheme is.
        --
        -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
        'folke/tokyonight.nvim',
        priority = 1000, -- Make sure to load this before all the other start plugins.
        init = function()
            -- Load the colorscheme here.
            -- Like many other themes, this one has different styles, and you could load
            -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
            vim.cmd.colorscheme('tokyonight-night')

            -- You can configure highlights by doing something like:
            vim.cmd.hi('Comment gui=none')
        end,
    },

    -- Highlight todo, notes, etc in comments
    {
        -- NOTE: adding a note
        -- PERF: fully optimised
        -- HACK: hmm, this looks a bit funky
        -- TODO: What else?
        -- FIX: this needs fixing
        -- WARNING: ??

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
                HELP = {
                    icon = '?',
                    color = '#1e8704',
                },
            },
            merge_keywords = true,
        },
        keys = {
            { '<leader>st', '<cmd>TodoTelescope<cr>', desc = '[S]earch [T]odotList' }, -- Using Telescope
        },
    },
}
