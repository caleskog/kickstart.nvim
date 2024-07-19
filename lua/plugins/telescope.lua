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
            'ThePrimeagen/git-worktree.nvim',
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
            --

            local actions = require('telescope.actions')
            local transform_mod = require('telescope.actions.mt').transform_mod
            local custom_actions = {}
            --- Open file with system default. create/re-create the corresponding html file.
            ---
            ---@param sources? table<string> A talbe specifying the filetypes that it tryes to convert to `target` before opening the file. Default: {"markdown"}
            ---@param target? string The filetype that it tries to convert into. Default: "html"
            custom_actions.system_default_html = function(sources, target)
                ---@param prompt_bufnr number The prompt bufnr
                return function(prompt_bufnr)
                    -- Info found at: https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/actions/set.lua#L127
                    sources = sources or { 'markdown' }
                    target = target or 'html'
                    local action_state = require('telescope.actions.state')
                    local entry = action_state.get_selected_entry()
                    actions.close(prompt_bufnr)
                    if not entry then
                        vim.notify('Nothing currently selected', vim.log.levels.WARN)
                        return
                    end
                    if entry.path or entry.filename then
                        local filename = entry.path or entry.filename
                        vim.notify(filename or 'Nil', vim.log.levels.INFO)
                        local util = require('../util')
                        util.open(vim.fn.fnameescape(filename), sources, target)
                    end
                    --[[ -- Use default open command
                    local action_set = require('telescope.actions.set')
                    return action_set.select(prompt_bufnr, 'default') ]]
                end
            end
            --- Transform custom_actions module and sets the correct metatables.
            --- These custom actions includes the following functions: `:replace(f)`, `:replace_if(f, c)`,
            --- `replace_map(tbl)` and `enhance(tbl)`. More information on these functions
            --- can be found in the `developers.md` and `lua/tests/automated/action_spec.lua`
            custom_actions = transform_mod(custom_actions)

            require('telescope').setup({
                -- You can put your default mappings / updates / etc. in here
                --  All the info you're looking for is in `:help telescope.setup()`
                --
                defaults = {
                    mappings = {
                        i = {
                            ['<C-j>'] = actions.cycle_history_next, -- To search forward of previous searches
                            ['<C-k>'] = actions.cycle_history_prev, -- To search backwards of previous searches
                            ['<C-s>'] = custom_actions.system_default_html(),
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
            pcall(require('telescope').load_extension('git_worktree'))

            local util = require('../util')

            -- See `:help telescope.builtin`
            local builtin = require('telescope.builtin')
            util.map('n', '<leader>fh', builtin.help_tags, 'Help')
            util.map('n', '<leader>fk', builtin.keymaps, 'Keymaps')
            util.map('n', '<leader>ff', builtin.find_files, 'Files')
            -- util.cmap('n', '<leader>sS', builtin.builtin, { desc = 'Search Select Telescope' })
            util.map('n', '<leader>fw', builtin.grep_string, 'Word')
            util.cmap('n', '<leader>fg', "lua require('telescope').extensions.live_grep_args.live_grep_args()", 'Grep')
            util.cmap('n', '<leader>fG', 'lua require("telescope.builtin").live_grep({ glob_pattern = "!{spec,test}"})', 'Grep (Code)')
            util.map('n', '<leader>fd', builtin.diagnostics, 'Diagnostics')
            -- util.cmap('n', '<leader>sr', builtin.resume, 'Search Resume' )
            util.map('n', '<leader>fr', builtin.oldfiles, 'Recent Files')
            util.map('n', '<leader>b', builtin.buffers, 'Find Buffers')
            -- util.cmap('n', '<leader>ga', 'AdvancedGitSearch', 'AdvancedGitSearch')

            -- Slightly advanced example of overriding default behavior and theme
            util.map('n', '<leader>/', function()
                -- You can pass additional configuration to Telescope to change the theme, layout, etc.
                builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
                    winblend = 10,
                    previewer = false,
                }))
            end, 'Buffer | Fuzzily search')

            -- Shortcut for searching your Neovim configuration files
            util.map('n', '<leader>fn', function()
                builtin.find_files({ cwd = vim.fn.stdpath('config') })
            end, 'Neovim')

            -- Search for snippets
            util.cmap('n', '<leader>fl', 'Telescope luasnip', "Luasnip's Snippets")
        end,
    },
}
