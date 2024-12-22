-- File: plugins/sessions.lua
-- Author: caleskog

return {
    {
        'rmagatti/auto-session',
        lazy = false,
        ---Enable autocomplete for opts
        ---@module "auto-session"
        ---@type AutoSession.Config
        opts = {
            suppressed_dirs = { '~/', '~/projects', '~/Downloads', '/' },

            -- Telescope integration
            session_lens = {
                path_display = { 'shorten' },
                load_on_setup = true,
                theme_conf = { border = true },
                previewer = false,
            },
        },
        keys = {
            { '<leader>wl', '<cmd>SessionSearch<CR>', desc = 'List sessions' },
            { '<leader>wS', '<cmd>SessionSave<CR>', desc = 'Save session' },
            { '<leader>wa', '<cmd>SessionToggleAutoSave<CR>', desc = 'Toggle autosave' },
        },
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
