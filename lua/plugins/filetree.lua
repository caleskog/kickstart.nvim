-- File: lua/custom/plugins/filetree.lua

return {
    -- {
    -- 'nvim-neo-tree/neo-tree.nvim',
    -- version = '*',
    -- dependencies = {
    --     'nvim-lua/plenary.nvim',
    --     'nvim-tree/nvim-web-devicons',
    --     'MunifTanjim/nui.nvim',
    --     -- '3rd/image.nvim', -- Image support in preview
    -- },
    -- config = function()
    --     require('neo-tree').setup({
    --         window = {
    --             mappings = {
    --                 ['e'] = function()
    --                     vim.api.nvim_exec2('Neotree focus filesystem left', { output = true })
    --                 end,
    --                 ['b'] = function()
    --                     vim.api.nvim_exec2('Neotree focus buffers left', { output = true })
    --                 end,
    --                 ['g'] = function()
    --                     vim.api.nvim_exec2('Neotree focus git_status left', { output = true })
    --                 end,
    --                 ['<C-u>'] = { 'scroll_preview', config = { direction = 10 } },
    --                 ['<C-d>'] = { 'scroll_preview', config = { direction = -10 } },
    --                 ['<C-b>'] = 'noop',
    --                 ['<C-f>'] = 'noop',
    --                 ['<C-s>'] = 'system_open',
    --             },
    --         },
    --         commands = {
    --             system_open = function(state)
    --                 local node = state.tree:get_node()
    --                 local path = node:get_id()
    --                 local util = require('../util')
    --                 util.open(path)
    --             end,
    --         },
    --     })
    -- end,
    -- keys = function() -- Funcion adapted from https://github.com/nvim-neo-tree/neo-tree.nvim/issues/1115#issuecomment-1784184617
    --     local find_buffer_by_type = function(type)
    --         for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    --             local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
    --             if ft == type then
    --                 return buf
    --             end
    -- end
    --         return -1
    --     end
    --     local toggle_neotree = function(toggle_command)
    --         if find_buffer_by_type('neo-tree') > 0 then
    --             require('neo-tree.command').execute({ action = 'close' })
    --         else
    --             toggle_command()
    --         end
    --     end
    --
    --     return {
    --         {
    --             '<leader>j',
    --             function()
    --                 toggle_neotree(function()
    --                     require('neo-tree.command').execute({ action = 'focus', reveal = true, dir = vim.uv.cwd() })
    --                 end)
    --             end,
    --             desc = 'Toggle File Explorer (cmd)',
    --         },
    --         {
    --             '<leader>J',
    --             function()
    --                 toggle_neotree(function()
    --                     require('neo-tree.command').execute({ action = 'focus', reveal = true })
    --                 end)
    --             end,
    --             desc = 'Toggle File Explorer (root)',
    --         },
    --     }
    -- end,
    -- },
    {
        'stevearc/oil.nvim',
        opts = {},
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        },
        config = function()
            require('oil').setup({
                default_file_explorer = true,
                delet_to_trash = true,
                skip_confirm_for_simple_edits = true,
                keymaps = {
                    ['<CR>'] = 'actions.select',
                    ['<C-s>'] = { 'actions.select', opts = { vertical = true }, desc = 'Open the entry in a vertical split' },
                    ['<C-h>'] = { 'actions.select', opts = { horizontal = true }, desc = 'Open the entry in a horizontal split' },
                    ['<C-t>'] = { 'actions.select', opts = { tab = true }, desc = 'Open the entry in new tab' },
                    -- Overriding the default 'gx' as I want to convert
                    -- markdown files to html and open the html file.
                    ['gx'] = {
                        function()
                            local oil = require('oil')
                            ---@diagnostic disable-next-line: different-requires
                            local util = require('../util')
                            local entry = oil.get_cursor_entry()
                            local dir = oil.get_current_dir()
                            if not entry or not dir then
                                return
                            end
                            local path = dir .. entry.name
                            util.open(path)
                        end,
                        mode = 'n',
                        desc = "Open file with system's default",
                    },
                },
                view_options = {
                    show_hidden = true,
                    natural_order = true,
                    is_always_hidden = function(name, _)
                        return name == '..' or name == '.git'
                    end,
                },
                win_options = {
                    wrap = true,
                },
            })
        end,
        keys = function()
            return {
                {
                    '<leader>j',
                    function()
                        local cwd = vim.fn.getcwd()
                        require('oil').toggle_float(cwd)
                    end,
                    desc = 'Toggle File Explorer (cmd)',
                },
                {
                    '-',
                    function()
                        local cd = require('oil').get_current_dir(0)
                        require('oil').toggle_float(cd)
                    end,
                    desc = 'Open parent directory',
                },
            }
        end,
    },
}
