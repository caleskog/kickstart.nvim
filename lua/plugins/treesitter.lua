-- File: plugins/treesitter.lua
-- Author: caleskog
-- Description: Everything todo with `nvim-treesitter`, i.e., highlight, edit, and navigate code.

---@return LazySpec
return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = { 'LazyFile', 'VeryLazy' },
        lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
        ---@type TSConfig
        ---@diagnostic disable-next-line: missing-fields
        opts = {
            ensure_installed = {
                'bash',
                'c',
                'cpp',
                'cmake',
                'diff',
                'html',
                'dockerfile',
                'javascript',
                'jsdoc',
                'json',
                'jsonc',
                'latex',
                'lua',
                'luadoc',
                'luap',
                'markdown',
                'markdown_inline',
                'printf',
                'python',
                'tmux',
                'gitignore',
                'query',
                'regex',
                'toml',
                'tsx',
                'typescript',
                'vim',
                'vimdoc',
                'xml',
                'yaml',
            },
            -- Autoinstall languages that are not installed
            auto_install = true,
            highlight = {
                enable = true,
                -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
                --  If you are experiencing weird indenting issues, add the language to
                --  the list of additional_vim_regex_highlighting and disabled languages for indent.
                -- additional_vim_regex_highlighting = { 'ruby' },
            },
            indent = {
                enable = true --[[ , disable = { 'ruby' } ]],
            },
            textobjects = { -- Taken from LazyVim: https://github.com/LazyVim/LazyVim/blob/d0c366e4d861b848bdc710696d5311dca2c6d540/lua/lazyvim/plugins/treesitter.lua
                move = {
                    enable = true,
                    goto_next_start = { [']f'] = '@function.outer', [']c'] = '@class.outer', [']a'] = '@parameter.inner' },
                    goto_next_end = { [']F'] = '@function.outer', [']C'] = '@class.outer', [']A'] = '@parameter.inner' },
                    goto_previous_start = { ['[f'] = '@function.outer', ['[c'] = '@class.outer', ['[a'] = '@parameter.inner' },
                    goto_previous_end = { ['[F'] = '@function.outer', ['[C'] = '@class.outer', ['[A'] = '@parameter.inner' },
                },
            },
        },
        config = function(_, opts)
            -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

            ---@diagnostic disable-next-line: missing-fields
            require('nvim-treesitter.configs').setup(opts)

            -- There are additional nvim-treesitter modules that you can use to interact
            -- with nvim-treesitter. You should go explore a few and see what interests you:
            --
            --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
            --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
            --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        event = 'VeryLazy',
        enabled = true,
        config = function()
            -- If treesitter is already loaded, we need to run config again for textobjects
            if Core.is_loaded('nvim-treesitter') then
                local opts = Core.opts('nvim-treesitter')
                ---@diagnostic disable-next-line: missing-fields
                require('nvim-treesitter.configs').setup({ textobjects = opts.textobjects })
            end

            --[[ ---@diagnostic disable-next-line: missing-fields
            require('nvim-treesitter.configs').setup({
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                        keymaps = {
                            ['a='] = { query = '@assignment.outer', desc = 'Around Assignment' },
                            ['i='] = { query = '@assignment.inner', desc = 'Inner Assignment' },
                            -- ['l='] = { query = '@assignment.lhs', desc = 'Assignment LHS' },
                            -- ['r='] = { query = '@assignment.rhs', desc = 'Assignment RHS' },

                            ['aa'] = { query = '@parameter.outer', desc = 'Around Parameter' },
                            ['ia'] = { query = '@parameter.inner', desc = 'Inner Parameter' },

                            ['af'] = { query = '@call.outer', desc = 'Around Function Call' },
                            ['if'] = { query = '@call.inner', desc = 'Inner Function Call' },

                            ['am'] = { query = '@function.outer', desc = 'Around Function' },
                            ['im'] = { query = '@function.inner', desc = 'Inner Function' },

                            ['ai'] = { query = '@conditional.outer', desc = 'Around Conditional' },
                            ['ii'] = { query = '@conditional.inner', desc = 'Inner Conditional' },

                            ['ac'] = { query = '@class.outer', desc = 'Around Class' },
                            ['ic'] = { query = '@class.inner', desc = 'Inner Class' },

                            ['aS'] = { query = '@statement.outer', desc = 'Around Statement' },
                            ['iS'] = { query = '@statement.inner', desc = 'Inner Statement' },

                            ['al'] = { query = '@loop.outer', desc = 'Around Loop' },
                            ['il'] = { query = '@loop.inner', desc = 'Inner Loop' },

                            ['ax'] = { query = '@comment.outer', desc = 'Around Comment' },
                            ['ix'] = { query = '@comment.inner', desc = 'Inner Comment' },
                        },
                    },
                    swap = {
                        enable = true,
                        swap_next = {
                            ['<leader>;a'] = '@parameter.inner', -- swap parameter with next
                            ['<leader>;m'] = '@function.outer', -- swap function with next
                        },
                        swap_previous = {
                            ['<leader>,A'] = '@parameter.inner', -- swap parameter with previous
                            ['<leader>,M'] = '@function.outer', -- swap function with previous
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true, -- whether to set jumps in the jumplist
                        goto_next_start = {
                            [']m'] = { query = '@function.outer', desc = 'Next Function' },
                            [']i'] = { query = '@conditional.outer', desc = 'Next Conditional' },
                            [']l'] = { query = '@loop.outer', desc = 'Next Loop' },
                            [']a'] = { query = '@parameter.outer', desc = 'Next Parameter' },
                            [']c'] = { query = '@class.outer', desc = 'Next Class' },
                        },
                        goto_next_end = {
                            [']M'] = { query = '@function.outer', desc = 'End Function' },
                            [']I'] = { query = '@conditional.outer', desc = 'End Conditional' },
                            [']L'] = { query = '@loop.outer', desc = 'End Loop' },
                            [']A'] = { query = '@parameter.outer', desc = 'End Parameter' },
                            [']C'] = { query = '@class.outer', desc = 'End Class' },
                        },
                        goto_previous_start = {
                            ['[m'] = { query = '@function.outer', desc = 'Previous Function' },
                            ['[i'] = { query = '@conditional.outer', desc = 'Previous Conditional' },
                            ['[l'] = { query = '@loop.outer', desc = 'Previous Loop' },
                            ['[a'] = { query = '@parameter.outer', desc = 'Previous Parameter' },
                            ['[c'] = { query = '@class.outer', desc = 'Previous Class' },
                        },
                        goto_previous_end = {
                            ['[M'] = { query = '@function.outer', desc = 'Start Function' },
                            ['[I'] = { query = '@conditional.outer', desc = 'Start Conditional' },
                            ['[L'] = { query = '@loop.outer', desc = 'Start Loop' },
                            ['[A'] = { query = '@parameter.outer', desc = 'Start Parameter' },
                            ['[C'] = { query = '@class.outer', desc = 'Start Class' },
                        },
                    },
                },
            }) ]]

            ---Taken from LazyVim: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/treesitter.lua
            -- When in diff mode, we want to use the default
            -- vim text objects c & C instead of the treesitter ones.
            local move = require('nvim-treesitter.textobjects.move') ---@type table<string,fun(...)>
            local configs = require('nvim-treesitter.configs')
            for name, fn in pairs(move) do
                if name:find('goto') == 1 then
                    move[name] = function(q, ...)
                        if vim.wo.diff then
                            local config = configs.get_module('textobjects.move')[name] ---@type table<string,string>
                            for key, query in pairs(config or {}) do
                                if q == query and key:find('[%]%[][cC]') then
                                    vim.cmd('normal! ' .. key)
                                    return
                                end
                            end
                        end
                        return fn(q, ...)
                    end
                end
            end

            -- NOTE: Dosen't work due to conflict with folke/flash.nvim
            --
            -- local ts_repeat_move = require('nvim-treesitter.textobjects.repeatable_move')
            --
            -- -- ; and , for repeating the last move in the direction you were moving.
            -- local util = require('util')
            -- util.fmap('nxo', ';', ts_repeat_move.repeat_last_move_opposite)
            -- util.fmap('nxo', ',', ts_repeat_move.repeat_last_move_next)

            -- local wk = require('which-key')
            -- Document Mini.AI custom textobjects for operator-pending mode
            -- Document Mini.AI custom textobjects for visual mode
            -- wk.add(which_key_spec({ 'o', 'x' }))
        end,
    },
}
