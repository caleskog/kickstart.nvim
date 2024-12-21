-- Author: caleskog

local util = require('util')

local function which_key_spec(mode)
    local desc_t = {
        util.WhichKey_ai(mode, '[a]rgument/parameter'),
        util.WhichKey_ai(mode, '[f]unction call'),
        util.WhichKey_ai(mode, '[m]unction'),
        util.WhichKey_ai(mode, 'cond[i]tional'),
        util.WhichKey_ai(mode, '[c]lass'),
        util.WhichKey_ai(mode, '[S]tatement'),
        util.WhichKey_ai(mode, '[l]oop'),
    }
    -- util.dump_dict(desc_t, 'desc_t_before.dump')
    desc_t = util.flatten(desc_t)
    -- util.dump_dict(desc_t, 'desc_t_after.dump')
    return desc_t
end

return {
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        lazy = true,
        config = function()
            ---@diagnostic disable-next-line: missing-fields
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
            })

            -- Dosen't work due to conflict with folke/flash.nvim
            -- local ts_repeat_move = require('nvim-treesitter.textobjects.repeatable_move')
            --
            -- -- ; and , for repeating the last move in the direction you were moving.
            -- util.fmap('nxo', ';', ts_repeat_move.repeat_last_move_opposite)
            -- util.fmap('nxo', ',', ts_repeat_move.repeat_last_move_next)

            -- local wk = require('which-key')
            -- Document Mini.AI custom textobjects for operator-pending mode
            -- Document Mini.AI custom textobjects for visual mode
            -- wk.add(which_key_spec({ 'o', 'x' }))
        end,
    },
}
