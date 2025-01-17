-- File: navigation.lua
-- Author: caleskog

return {
    {
        'aserowy/tmux.nvim',
        event = 'VimEnter',
        config = function()
            return require('tmux').setup({
                copy_sync = {
                    -- enables copy sync. by default, all registers are synchronized.
                    -- to control which registers are synced, see the `sync_*` options.
                    enable = false,
                    -- ignore specific tmux buffers e.g. buffer0 = true to ignore the
                    -- first buffer or named_buffer_name = true to ignore a named tmux
                    -- buffer with name named_buffer_name :)
                    ignore_buffers = { empty = false },
                    -- TMUX >= 3.2: all yanks (and deletes) will get redirected to system
                    -- clipboard by tmux
                    redirect_to_clipboard = true,
                    -- offset controls where register sync starts
                    -- e.g. offset 2 lets registers 0 and 1 untouched
                    register_offset = 0,
                    -- overwrites vim.g.clipboard to redirect * and + to the system
                    -- clipboard using tmux. If you sync your system clipboard without tmux,
                    -- disable this option!
                    sync_clipboard = false,
                    -- synchronizes registers *, +, unnamed, and 0 till 9 with tmux buffers.
                    sync_registers = false,
                    -- syncs deletes with tmux clipboard as well, it is adviced to
                    -- do so. Nvim does not allow syncing registers 0 and 1 without
                    -- overwriting the unnamed register. Thus, ddp would not be possible.
                    sync_deletes = false,
                    -- syncs the unnamed register with the first buffer entry from tmux.
                    sync_unnamed = false,
                },
                navigation = {
                    -- cycles to opposite pane while navigating into the border
                    cycle_navigation = true,
                    -- enables default keybindings (C-hjkl) for normal mode
                    enable_default_keybindings = false,
                    -- prevents unzoom tmux when navigating beyond vim border
                    persist_zoom = false,
                },
                resize = {
                    -- enables default keybindings (A-hjkl) for normal mode
                    enable_default_keybindings = false,
                    -- sets resize steps for x axis
                    resize_step_x = 5,
                    -- sets resize steps for y axis
                    resize_step_y = 5,
                },
            })
        end,
        -- stylua: ignore
        keys = {
            -- Navigation
            -- {"<C-l>", function() require('tmux').move_left() end, desc = 'Move to the left'}, -- Keybinding used to clear search highlights
            {"<C-j>", function() require('tmux').move_bottom() end, desc = 'Move to the bottom'},
            {"<C-k>", function() require('tmux').move_top() end, desc = 'Move to the top'},
            {"<C-h>", function() require('tmux').move_right() end, desc = 'Move to the right'},
            {"<C-Left>", function() require('tmux').move_left() end, desc = 'Move to the left'},
            {"<C-Down>", function() require('tmux').move_bottom() end, desc = 'Move to the bottom'},
            {"<C-Up>", function() require('tmux').move_top() end, desc = 'Move to the top'},
            {"<C-Right>", function() require('tmux').move_right() end, desc = 'Move to the right'},
            -- Resize
            {"<A-l>", function() require('tmux').resize_left() end, desc = 'Resize to the left'},
            {"<A-j>", function() require('tmux').resize_bottom() end, desc = 'Resize to the bottom'},
            {"<A-k>", function() require('tmux').resize_top() end, desc = 'Resize to the top'},
            {"<A-h>", function() require('tmux').resize_right() end, desc = 'Resize to the right'},
            {"<A-Left>", function() require('tmux').resize_left() end, desc = 'Resize to the left'},
            {"<A-Down>", function() require('tmux').resize_bottom() end, desc = 'Resize to the bottom'},
            {"<A-Up>", function() require('tmux').resize_top() end, desc = 'Resize to the top'},
            {"<A-Right>", function() require('tmux').resize_right() end, desc = 'Resize to the right'},
        }
,
    },
    {
        'folke/flash.nvim',
        event = 'VeryLazy',
        ---@type Flash.Config
        opts = {},
        keys = { -- NOTE: Flash can search treesitter nodes too.
            {
                's',
                mode = { 'n', 'x', 'o' },
                function()
                    require('flash').jump()
                end,
                desc = 'Flash',
            },
            {
                'r',
                mode = 'o',
                function()
                    require('flash').remote()
                end,
                desc = 'Remote Flash',
            },
            {
                '<c-s>',
                mode = { 'c' },
                function()
                    require('flash').toggle()
                end,
                desc = 'Toggle Flash Search',
            },
        },
    },
}
