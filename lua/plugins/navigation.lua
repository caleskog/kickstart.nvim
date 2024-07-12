-- File: navigation.lua
-- Author: caleskog

return {
    -- {
    --     'christoomey/vim-tmux-navigator',
    --     cmd = {
    --         'TmuxNavigateLeft',
    --         'TmuxNavigateDown',
    --         'TmuxNavigateUp',
    --         'TmuxNavigateRight',
    --         'TmuxNavigatePrevious',
    --     },
    --     keys = {
    --         { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
    --         { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>' },
    --         { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>' },
    --         { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>' },
    --         { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
    --     },
    -- },
    {
        'aserowy/tmux.nvim',
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
                    enable_default_keybindings = true,

                    -- prevents unzoom tmux when navigating beyond vim border
                    persist_zoom = false,
                },
                resize = {
                    -- enables default keybindings (A-hjkl) for normal mode
                    enable_default_keybindings = true,

                    -- sets resize steps for x axis
                    resize_step_x = 5,

                    -- sets resize steps for y axis
                    resize_step_y = 5,
                },
            })
        end,
    },
}