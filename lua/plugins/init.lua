-- Fike: plugins/init.lua
-- Author: calgeskog
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

    -- This is often very useful to both group configuration, as well as handle
    -- lazy loading plugins that don't need to be loaded immediately at startup.
    --
    -- For example, in the following configuration, we use:
    --  event = 'VimEnter'
    --
    -- which loads which-key before all the UI elements are loaded. Events can be
    -- normal autocommands events (`:help autocmd-events`).
    --
    -- Then, because we use the `config` key, the configuration only runs
    -- after the plugin has been loaded:
    --  config = function() ... end

    { -- Useful plugin to show you pending keybinds.
        'folke/which-key.nvim',
        event = 'VimEnter', -- Sets the loading event to 'VimEnter'
        config = function() -- This is the function that runs, AFTER loading
            require('which-key').setup()

            -- Document existing key chains
            require('which-key').register({
                ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
                ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
                ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
                ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
                ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
            })
        end,
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
}
