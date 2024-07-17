-- File: plugins/git.lua
-- Author: caleskog

return {
    {
        'NeogitOrg/neogit',
        dependencies = {
            'nvim-lua/plenary.nvim', -- required
            'sindrets/diffview.nvim', -- optional - Diff integration
            'nvim-telescope/telescope.nvim', -- or "ibhagwan/fzf-lua"
        },
        config = function()
            local util = require('../util')
            local neogit = require('neogit')
            local telescope = require('telescope.builtin')

            util.fmap('n', '<leader>gg', neogit.open, 'Open Neogit')
            util.cmap('n', '<leader>gc', 'Neogit commit', 'Git Commit')
            util.cmap('n', '<leader>gp', 'Neogit pull', 'Git Pull')
            util.cmap('n', '<leader>gP', 'Neogit push', 'Git Push')

            -- Telescope specific mappings
            util.fmap('n', '<leader>fc', telescope.git_commits, 'Git Commits')
            util.fmap('n', '<leader>fC', telescope.git_bcommits, 'Buffer | Git Commits')
            util.fmap('n', '<leader>fb', telescope.git_branches, 'Git Branches')

            neogit.setup({})
        end,
    },
}
