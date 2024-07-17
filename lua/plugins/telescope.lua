-- File: plugins/fuzzy-finder.lua
-- Author: caleskog
-- Description: Loading plugins that do fuzzy searches of files, lsp, etc.

return {
    {
        'nvim-telescope/telescope.nvim',
        event = 'VimEnter',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            { -- If encountering errors, see telescope-fzf-native README for installation instructions
                'nvim-telescope/telescope-fzf-native.nvim',

                -- `build` is used to run some command when the plugin is installed/updated.
                -- This is only run then, not every time Neovim starts up.
                build = 'make',

                -- `cond` is a condition used to determine whether this plugin should be installed and loaded.
                cond = function()
                    return vim.fn.executable('make') == 1
                end,
            },
            { 'nvim-telescope/telescope-ui-select.nvim' },

            -- Useful for getting pretty icons, but requires a Nerd Font.
            { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },

            'debugloop/telescope-undo.nvim',
            'nvim-telescope/telescope-live-grep-args.nvim',
            -- {
            --     'aaronhallaert/advanced-git-search.nvim',
            --     dependencies = {
            --         'nvim-telescope/telescope.nvim',
            --         'tpope/vim-fugitive',
            --         'tpope/vim-rhubarb',
            --     },
            -- },
            'benfowler/telescope-luasnip.nvim',
        },
        config = function()
            -- Telescope is a fuzzy finder that comes with a lot of different things that
            -- it can fuzzy find! It's more than just a "file finder", it can search
            -- many different aspects of Neovim, your workspace, LSP, and more!
            --
            -- The easiest way to use Telescope, is to start by doing something like:
            --  :Telescope help_tags
            --
            -- After running this command, a window will open up and you're able to
            -- type in the prompt window. You'll see a list of `help_tags` options and
            -- a corresponding preview of the help.
            --
            -- Two important keymaps to use while in Telescope are:
            --  - Insert mode: <c-/>
            --  - Normal mode: ?
            --
            -- This opens a window that shows you all of the keymaps for the current
            -- Telescope picker. This is really useful to discover what Telescope can
            -- do as well as how to actually do it!

            -- [[ Configure Telescope ]]
            -- See `:help telescope` and `:help telescope.setup()`
            local actions = require('telescope.actions')
            require('telescope').setup({
                -- You can put your default mappings / updates / etc. in here
                --  All the info you're looking for is in `:help telescope.setup()`
                --
                defaults = {
                    mappings = {
                        i = {
                            ['<C-j>'] = actions.cycle_history_next, -- To search forward of previous searches
                            ['<C-k>'] = actions.cycle_history_prev, -- To search backwards of previous searches
                        },
                    },
                },
                pickers = {
                    find_files = { -- For finding hidden files
                        -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
                        find_command = { 'rg', '--files', '--hidden', '--glob', '!**/.git/*' },
                    },
                },
                extensions = {
                    ['ui-select'] = {
                        require('telescope.themes').get_dropdown(),
                    },
                    undo = {
                        use_delta = true,
                        use_custom_command = nil, -- setting this implies `use_delta = false`. Accepted format is: { "bash", "-c", "echo '$DIFF' | delta" }
                        side_by_side = false,
                        vim_diff_opts = { ctxlen = vim.o.scrolloff },
                        entry_format = 'state #$ID, $STAT, $TIME',
                        mappings = { -- TODO: Don't know if these works or not?
                            i = {
                                ['<C-cr>'] = require('telescope-undo.actions').yank_additions,
                                ['<S-cr>'] = require('telescope-undo.actions').yank_deletions,
                                ['<cr>'] = require('telescope-undo.actions').restore,
                            },
                        },
                    },
                },
            })

            -- Enable Telescope extensions if they are installed
            pcall(require('telescope').load_extension, 'fzf')
            pcall(require('telescope').load_extension, 'ui-select')
            pcall(require('telescope').load_extension('undo'))
            pcall(require('telescope').load_extension('live_grep_args'))
            -- pcall(require('telescope').load_extension('advanced_git_search'))
            pcall(require('telescope').load_extension('luasnip'))

            local util = require('../util')

            -- See `:help telescope.builtin`
            local builtin = require('telescope.builtin')
            util.map('n', '<leader>fh', builtin.help_tags, '[H]elp')
            util.map('n', '<leader>fk', builtin.keymaps, '[K]eymaps')
            util.map('n', '<leader>ff', builtin.find_files, '[F]iles')
            -- util.cmap('n', '<leader>sS', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
            util.map('n', '<leader>fw', builtin.grep_string, '[W]ord')
            util.cmap('n', '<leader>fg', "lua require('telescope').extensions.live_grep_args.live_grep_args()", 'Live [G]rep}')
            util.cmap('n', '<leader>fc', 'lua require("telescope.builtin").live_grep({ glob_pattern = "!{spec,test}"})', 'Live Grep [C]ode')
            util.map('n', '<leader>fd', builtin.diagnostics, '[D]iagnostics')
            -- util.cmap('n', '<leader>sr', builtin.resume, '[S]earch [R]esume' )
            util.map('n', '<leader>fr', builtin.oldfiles, '[R]ecent Files')
            util.map('n', '<leader>fb', builtin.buffers, '[B]uffers')
            -- util.cmap('n', '<leader>ga', 'AdvancedGitSearch', '[A]dvancedGitSearch')

            -- Slightly advanced example of overriding default behavior and theme
            util.map('n', '<leader>/', function()
                -- You can pass additional configuration to Telescope to change the theme, layout, etc.
                builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
                    winblend = 10,
                    previewer = false,
                }))
            end, 'Current Buffer: Fuzzily search')

            -- Shortcut for searching your Neovim configuration files
            util.map('n', '<leader>fn', function()
                builtin.find_files({ cwd = vim.fn.stdpath('config') })
            end, '[N]eovim')

            -- Search for snippets
            util.cmap('n', '<leader>fl', 'Telescope luasnip', "[L]uasnip's snippets")
        end,
    },
}
