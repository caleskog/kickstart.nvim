---@author caleskog

return {
    {
        'rcarriga/nvim-notify',
        enabled = Core.config.is('notifier', 'nvim-notify'), -- disable if snacks.notifier is enabled
        opts = {
            stages = 'fade',
        },
        config = function(_, opts)
            local notify = require('notify')
            vim.notify = notify
            ---@diagnostic disable-next-line: missing-fields
            notify.setup(opts)
        end,
    },
    {
        'snacks.nvim',
        ---@module 'snacks'
        ---@type snacks.Config
        opts = {
            notifier = {
                enabled = Core.config.is('notifier', 'snacks'),
                style = 'fancy',
                -- level = vim.log.levels.INFO,
            },
        },
        -- stylua: ignore
        keys = {
            { '<leader>n', function() Snacks.notifier.show_history() end, desc = 'Notification History' },
        },
    },
    {
        'folke/noice.nvim',
        event = 'VeryLazy',
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            -- 'MunifTanjim/nui.nvim', -- Loaded see `ui/ui.lua`
            -- 'nvim-telescope/telescope.nvim', -- Already loaded at VimEnter, see `telescope.lua`
        },
        opts = {
            lsp = {
                -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                override = {
                    ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
                    ['vim.lsp.util.stylize_markdown'] = true,
                    ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
                },
            },
            -- you can enable a preset for easier configuration
            presets = {
                bottom_search = true, -- use a classic bottom cmdline for search
                command_palette = false, -- position the cmdline and popupmenu together
                long_message_to_split = true, -- long messages will be sent to a split
                inc_rename = false, -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = true, -- add a border to hover docs and signature help
            },
            routes = {
                { -- Hide search virtual text
                    filter = {
                        event = 'msg_show',
                        kind = 'search_count',
                    },
                    opts = { skip = true },
                },
                {
                    filter = {
                        event = 'msg_show',
                        any = {
                            { find = '%d+L, %d+B' }, -- written
                            { find = '; after #%d+' }, -- after
                            { find = '; before #%d+' }, -- before
                        },
                    },
                    view = 'mini',
                },
                -- The following doesn't work (never triggers)
                -- {
                --     filter = {
                --         event = 'notify',
                --         find = 'Neogit', -- neogit
                --     },
                --     view = 'mini',
                -- },
            },
        },
        -- stylua: ignore
        keys = {
            { '<leader>sn', '', desc = '+noice' },
            { '<leader>sna', function() require('noice').cmd('all') end, desc = 'Noice All' },
            { '<leader>snd', function() require('noice').cmd('dismiss') end, desc = 'Noice Dismiss' },
            { '<leader>snl', function() require('noice').cmd('last') end, desc = 'Noice Last Message' },
            { '<leader>snh', function() require('noice').cmd('history') end, desc = 'Noice history' },
            { '<leader>snt', function() require('noice').cmd('pick') end, desc = 'Noice Picker (Telescope)' },
            -- TODO: Doesn't seem to work correctly.
            { '<c-f>', function() if not require('noice.lsp').scroll(4) then return '<c-f>' end end, silent = true, expr = true, desc = 'Scroll Forward', mode = { 'i', 'n', 's' } },
            -- TODO: Doesn't seem to work correctly.
            { '<c-b>', function() if not require('noice.lsp').scroll(-4) then return '<c-b>' end end, silent = true, expr = true, desc = 'Scroll Backward', mode = { 'i', 'n', 's' } },

            { '"',
                function()
                    gprint('Noice', 'This is a notification')
                    gpdbg('Noice', 'This is a notification with debug')
                end,
                desc = 'Test notification view',
            },
        },
        config = function(_, opts)
            -- HACK: noice shows messages from before it was enabled,
            -- but this is not ideal when Lazy is installing plugins,
            -- so clear the messages in this case.
            if vim.o.filetype == 'lazy' then
                vim.cmd([[messages clear]])
            end
            require('noice').setup(opts)
        end,
    },
}
