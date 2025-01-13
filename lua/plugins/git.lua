-- File: plugins/git.lua
-- Author: caleskog

local key = Core.utils.keymap

local function git()
    local root = vim.fn.expand('%:p:h')
    local git_root = vim.fs.find('.git', { path = root, upward = true })[1]
    local ret = git_root and vim.fn.fnamemodify(git_root, ':h') or root
    return ret
end

return {
    { -- Adds git related signs to the gutter, as well as utilities for managing changes
        'lewis6991/gitsigns.nvim',
        event = 'LazyFile',
        ---@module 'gitsigns'
        ---@type Gitsigns.Config
        ---@diagnostic disable: missing-fields
        opts = {
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                changedelete = { text = '~' },
                delete = { text = '' },
                topdelete = { text = '' },
            },
            signs_staged = {
                add = { text = '+' },
                change = { text = '~' },
                changedelete = { text = '~' },
                delete = { text = '' },
                topdelete = { text = '' },
            },
            -- Taken from LazyVim:
            -- https://github.com/LazyVim/LazyVim/blob/d1529f650fdd89cb620258bdeca5ed7b558420c7/lua/lazyvim/plugins/editor.lua#L268
            on_attach = function(bufnr)
                local gs = require('gitsigns')

                local function map(mode, l, r, desc)
                    key.bmap(bufnr, mode, l, r, desc)
                end

                -- stylua: ignore start
                map('n', ']h', function()
                    if vim.wo.diff then
                        vim.cmd.normal({"]c",bang=true})
                    else
                        gs.nav_hunk("next")
                    end
                end, "Next Hunk")
                map('n', '[h', function()
                    if vim.wo.diff then
                        vim.cmd.normal({ '[c', bang = true })
                    else
                        gs.nav_hunk('prev')
                    end
                end, 'Prev Hunk')
                map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
                map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
                map("nv", "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
                map("nv", "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
                map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
                map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
                map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
                map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
                map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
                map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
                map("n", "<leader>ghd", gs.diffthis, "Diff This")
                map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
                map("ox", "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
            end,
        },
    },
    {
        'snacks.nvim',
        ---@module 'snacks'
        ---@type snacks.Config
        -- stylua: ignore
        opts = {
            git = { enabled = true, }, -- correct?
            gitbrowse = { enabled = true, }, -- correct?
            -- lazygit = { enabled = true, }, -- correct?
        },
        -- IMPORTANT: Might not work to have 'config' here too, as it exists in plugins/init.lua
        --[[ config = function(_, _)
            -- stylua: ignore start
            if vim.fn.executable('lazygit') == 1 then
                local git_root = git()
                key.fmap("n", "<leader>gg", function() Snacks.lazygit( { cwd = git_root }) end, "Lazygit (Root Dir)" )
                key.fmap("n", "<leader>gG", function() Snacks.lazygit() end, "Lazygit (cwd)" )
                key.fmap("n", "<leader>gf", function() Snacks.lazygit.log_file() end, "Lazygit Current File History" )
                key.fmap("n", "<leader>gl", function() Snacks.lazygit.log({ cwd = git_root }) end, "Lazygit Log" )
                key.fmap("n", "<leader>gL", function() Snacks.lazygit.log() end, "Lazygit Log (cwd)" )
            end
            -- stylua: ignore end
        end, ]]
        -- stylua: ignore
        -- TODO: This does not work!! Why?
        keys = {
            { '<leader>gb', function() Snacks.git.blame_line() end, desc = 'Git Blame Line'},
            { '<leader>gB', function() Snacks.gitbrowse() end, desc = 'Git Browse (open)' },
            { '<leader>gY', function ()
                    Snacks.gitbrowse({ open = function(url) vim.fn.setreg('+', url) end, notify = false })
            end, desc = "Git Browse (copy)" }
        },
    },
    {
        'NeogitOrg/neogit',
        enabled = false,
        dependencies = {
            'nvim-lua/plenary.nvim', -- required
            'sindrets/diffview.nvim', -- optional - Diff integration
            'nvim-telescope/telescope.nvim', -- or "ibhagwan/fzf-lua"
        },
        ---@module 'neogit'
        ---@type NeogitConfig
        opts = {
            kind = 'floating',
        },
        config = function(_, opts)
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

            neogit.setup(opts)
        end,
    },
}
