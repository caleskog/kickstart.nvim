---@author caleskog
---@description Loading plugins that do fuzzy searches of files, lsp, etc.

local ASSOCIATED_EXTENSIONS = {
    'fzf',
    'ui-select',
    'undo',
    'live_grep_args',
    'luasnip',
    'git_worktree',
}

-- File type to be associated with the previewer
-- See `bat --list-languages` for a list of supported values
local ASSOCIATE_FT = {
    -- C header and source files before M4 preprocessing
    ['c.in'] = 'c',
    ['h.in'] = 'c',
    -- C++ header and source files before M4 preprocessing
    ['cpp.in'] = 'cpp',
    ['hh.in'] = 'cpp',
    ['cc.in'] = 'cpp',
    ['hpp.in'] = 'cpp',
}

--- Enable Telescope extensions if they are installed
local function load_extentions()
    for _, ext in ipairs(ASSOCIATED_EXTENSIONS) do
        pcall(require('telescope').load_extension, ext)
    end
end

--- Set keymaps
local function keymaps()
    local key = Core.utils.keymap

    -- See `:help telescope.builtin`
    local builtin = require('telescope.builtin')
    key.map('n', '<leader>sh', builtin.help_tags, 'Help')
    key.map('n', '<leader>sk', builtin.keymaps, 'Keymaps')
    key.map('n', '<leader>ff', builtin.find_files, 'Files')
    -- key.cmap('n', '<leader>sS', builtin.builtin, { desc = 'Search Select Telescope' })
    key.map('n', '<leader>sg', builtin.live_grep, 'Grep')
    key.map('n', '<leader>sd', builtin.diagnostics, 'Diagnostics')
    -- key.cmap('n', '<leader>sr', builtin.resume, 'Search Resume' )
    -- key.map('n', '<leader>fr', builtin.oldfiles, 'Recent files')
    key.map('n', '<leader>fr', function()
        local picker = require('plugins.telescope.pickers.oldfiles')
        picker.oldfiles({
            cwd_only = true,
            always_include_current_session = true,
        })
    end, 'Recent files')
    key.map('n', '<leader>b', builtin.buffers, 'buffers')
    -- key.cmap('n', '<leader>ga', 'AdvancedGitSearch', 'AdvancedGitSearch')

    -- Slightly advanced example of overriding default behavior and theme
    key.map('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
            winblend = 10,
            previewer = false,
        }))
    end, 'Buffer | Fuzzily search')

    -- Shortcut for searching your Neovim configuration files
    key.map('n', '<leader>fn', function()
        builtin.find_files({ cwd = vim.fn.stdpath('config') })
    end, 'Neovim')

    ---------------------- Extensions' Keymaps ----------------------
    -- Live grep
    -- key.cmap('n', '<leader>sg', "lua require('telescope').extensions.live_grep_args.live_grep_args()", 'Grep')
    -- key.cmap('n', '<leader>sG', 'lua require("telescope.builtin").live_grep({ glob_pattern = "!{spec,test}"})', 'Grep (Code)')
    -- Search for snippets
    key.cmap('n', '<leader>sl', 'Telescope luasnip', 'Snippets')
end

---------------------------------------------------------------------------
---------------------- Telescope Configuration Start ----------------------
return {
    {
        'nvim-telescope/telescope.nvim',
        event = 'VimEnter',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make',
                -- `cond` is a condition used to determine whether this plugin should be installed and loaded.
                cond = function()
                    return vim.fn.executable('make') == 1
                end,
            },
            { 'nvim-telescope/telescope-ui-select.nvim' },
            { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
            'debugloop/telescope-undo.nvim',
            'nvim-telescope/telescope-live-grep-args.nvim',
            'benfowler/telescope-luasnip.nvim',
            'ThePrimeagen/git-worktree.nvim',
        },
        config = function()
            local actions = require('telescope.actions')
            local custom_actions = require('plugins.telescope.actions.system-defaults')
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
                    preview = {
                        -- For viewing pre-preprocessed files
                        filetype_hook = function(filepath, bufnr, _)
                            local ft = vim.fn.fnamemodify(filepath, ':e:e')
                            if ASSOCIATE_FT[ft] then
                                ft = ASSOCIATE_FT[ft]
                                vim.bo[bufnr].filetype = ft
                            end
                            return true
                        end,
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

            load_extentions()
            keymaps()
        end,
    },
}
