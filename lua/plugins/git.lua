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
            local key = Core.utils.keymap
            local neogit = require('neogit')
            local telescope = require('telescope.builtin')

            key.fmap('n', '<leader>gs', neogit.open, 'Open Neogit')
            key.cmap('n', '<leader>gc', 'Neogit commit', 'Git Commit')
            key.cmap('n', '<leader>gp', 'Neogit pull', 'Git Pull')
            key.cmap('n', '<leader>gP', 'Neogit push', 'Git Push')

            -- Telescope specific mappings
            key.fmap('n', '<leader>fc', telescope.git_commits, 'Git Commits')
            key.fmap('n', '<leader>fC', telescope.git_bcommits, 'Buffer | Git Commits')
            key.fmap('n', '<leader>fb', telescope.git_branches, 'Git Branches')

            key.cmap('n', '<leader>gw', "lua require('telescope').extensions.git_worktree.git_worktrees()", 'Git Worktrees')
            key.cmap('n', '<leader>gW', "lua require('telescope').extensions.git_worktree.create_git_worktree()", 'Create Git Worktree')

            neogit.setup({})
        end,
    },
}
