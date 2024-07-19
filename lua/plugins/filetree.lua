-- File: lua/custom/plugins/filetree.lua

return {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-tree/nvim-web-devicons',
        'MunifTanjim/nui.nvim',
        -- '3rd/image.nvim', -- Image support in preview
    },
    config = function()
        require('neo-tree').setup({
            window = {
                mappings = {
                    ['e'] = function()
                        vim.api.nvim_exec2('Neotree focus filesystem left', { output = true })
                    end,
                    ['b'] = function()
                        vim.api.nvim_exec2('Neotree focus buffers left', { output = true })
                    end,
                    ['g'] = function()
                        vim.api.nvim_exec2('Neotree focus git_status left', { output = true })
                    end,
                    ['<C-u>'] = { 'scroll_preview', config = { direction = 10 } },
                    ['<C-d>'] = { 'scroll_preview', config = { direction = -10 } },
                    ['<C-b>'] = 'noop',
                    ['<C-f>'] = 'noop',
                    ['O'] = 'system_open',
                },
            },
            commands = {
                system_open = function(state)
                    local node = state.tree:get_node()
                    local path = node:get_id()
                    vim.fn.jobstart({ 'xdg-open', path }, { detach = true })
                end,
            },
        })
    end,
    keys = function() -- Funcion adapted from https://github.com/nvim-neo-tree/neo-tree.nvim/issues/1115#issuecomment-1784184617
        local find_buffer_by_type = function(type)
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
                if ft == type then
                    return buf
                end
            end
            return -1
        end
        local toggle_neotree = function(toggle_command)
            if find_buffer_by_type('neo-tree') > 0 then
                require('neo-tree.command').execute({ action = 'close' })
            else
                toggle_command()
            end
        end

        return {
            {
                '<leader>j',
                function()
                    toggle_neotree(function()
                        require('neo-tree.command').execute({ action = 'focus', reveal = true, dir = vim.uv.cwd() })
                    end)
                end,
                desc = 'Toggle File Explorer (cmd)',
            },
            {
                '<leader>J',
                function()
                    toggle_neotree(function()
                        require('neo-tree.command').execute({ action = 'focus', reveal = true })
                    end)
                end,
                desc = 'Toggle File Explorer (root)',
            },
        }
    end,
}
