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
                },
            },
        })
    end,
    keys = {
        {
            '<leader>j',
            function()
                require('neo-tree.command').execute({
                    toggle = true,
                    source = 'filesystem',
                    position = 'left',
                })
            end,
            desc = 'Toggle Neotree',
        },
    },
}
