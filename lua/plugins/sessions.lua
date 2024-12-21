-- File: plugins/sessions.lua
-- Author: caleskog

local util = require('util')

return {
    {
        'rmagatti/auto-session',
        config = function()
            require('auto-session').setup({
                auto_session_suppress_dirs = { '~/', '~/projects', '~/Downloads', '/' },

                -- Telescope integration
                session_lens = {
                    buftypes_to_ignore = {},
                    load_on_setup = true,
                    theme_conf = { border = true },
                    previewer = false,
                },
                util.fmap('n', '<leader>wS', require('auto-session.session-lens').search_session, 'List Sessions', { noremap = true }),
            })
        end,
    },
    -- {
    --     'jedrzejboczar/possession.nvim',
    --     dependencies = {
    --         'nvim-lua/plenary.nvim',
    --         'nvim-telescope/telescope.nvim',
    --     },
    --     config = function()
    --         local Path = require('plenary.path')
    --         local plugin_dir = Path:new(vim.fn.stdpath('data'), 'possession')
    --         if not plugin_dir:is_dir() then
    --             plugin_dir:mkdir()
    --         end
    --         require('possession').setup({
    --             session_dir = plugin_dir:absolute(),
    --             autosave = {
    --                 on_quit = true,
    --             },
    --             plugins = {
    --                 neo_tree = true,
    --             },
    --         })
    --
    --         require('telescope').load_extension('possession')
    --
    --         local possession = require('telescope').extensions.possession
    --         util.map('n', '<leader>ss', possession.liat(), '[S]earch all [S]essions')
    --     end,
    -- },
    -- {
    --     'tpope/vim-obsession',
    -- },
}
