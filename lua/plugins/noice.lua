---@name plugins/noice.lua
---@author caleskog

return {
    {
        'rcarriga/nvim-notify',
        enable = Core.config.is('notifier', 'nvim-notify'), -- disable if snacks.notifier is enabled
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
        'folke/noice.nvim',
        event = 'VeryLazy',
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            'MunifTanjim/nui.nvim',
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            -- 'rcarriga/nvim-notify',
            'nvim-telescope/telescope.nvim', -- Already loaded at VimEnter, see `telescope.lua`
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
            },
        },
        keys = {
            { '<leader>fH', '<CMD>Noice telescope<CR>', desc = 'Notification history' },
            {
                '"',
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
