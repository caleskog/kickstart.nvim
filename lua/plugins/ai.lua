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

local function which_key_spec2(mode)
    local desc_t = {
        util.WhichKey_ai(mode, '[a]rgument/parameter'),
        -- util.WhichKey_ai(mode, '[f]unction call'),
        util.WhichKey_ai(mode, '[f]unction'),
        util.WhichKey_ai(mode, 'Cond[i]tional'),
        util.WhichKey_ai(mode, '[c]lass'),
        util.WhichKey_ai(mode, '[S]tatement'),
        util.WhichKey_ai(mode, '[l]oop'),
        -- util.WhichKey_ai('[b]lock'),    --TODO: 'ab' and 'ib' doeen't show up in which-key. I don't know if it uses the treesitter version or not?

        -- The following didn't work due to errors in which-key on start-up
        -- B = false, -- Disabling aB and iB as treesitter is a better option for block searches
    }
    -- util.dump_dict(desc_t, 'desc_t_before.dump')
    desc_t = util.flatten(desc_t)
    -- util.dump_dict(desc_t, 'desc_t_after.dump')
    return desc_t
end

local function mini_ai()
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [']quote
    --  - ci'  - [C]hange [I]nside [']quote
    local setup_tlb = {
        n_lines = 500,
        mappings = {
            -- Next/last textobject
            around_next = 'a;',
            inside_next = 'i;',
            around_last = 'a,',
            inside_last = 'i,',
        },
    }
    if util.module_mxists('nvim-treesitter-textobjects') then
        local spec_treesitter = require('mini.ai').gen_spec.treesitter
        setup_tlb['custom_textobjects'] = {
            a = spec_treesitter({ a = '@parameter.outer', i = '@parameter.inner' }),
            f = spec_treesitter({ a = '@call.outer', i = '@call.inner' }),
            m = spec_treesitter({ a = '@function.outer', i = '@function.inner' }),
            i = spec_treesitter({ a = '@conditional.outer', i = '@conditional.inner' }),
            c = spec_treesitter({ a = '@class.outer', i = '@class.inner' }),
            S = spec_treesitter({ a = '@statement.outer', i = '@statement.inner' }),
            l = spec_treesitter({ a = '@loop.outer', i = '@loop.inner' }),
            x = spec_treesitter({ a = '@comment.outer', i = '@comment.outer' }),
            -- ['='] = spec_treesitter({ a = '@assignment.outer', i = '@assignment.inner' }),
            -- b = spec_treesitter({ a = '@block.outer', i = '@block.inner' }),
        }
    end

    require('mini.ai').setup(setup_tlb)

    local wk = require('which-key')
    -- Document Mini.AI custom textobjects for operator-pending mode
    -- Document Mini.AI custom textobjects for visual mode
    wk.add(which_key_spec({ 'o', 'x' }))
end

return {
    {
        'echasnovski/mini.ai',
        event = 'VeryLazy',
        opts = function()
            local ai = require('mini.ai')
            return {
                n_lines = 500,
                custom_textobjects = {
                    o = ai.gen_spec.treesitter({ -- code block
                        a = { '@block.outer', '@conditional.outer', '@loop.outer' },
                        i = { '@block.inner', '@conditional.inner', '@loop.inner' },
                    }),
                    f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }), -- function
                    c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }), -- class
                    t = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' }, -- tags
                    d = { '%f[%d]%d+' }, -- digits
                    e = { -- Word with case
                        { '%u[%l%d]+%f[^%l%d]', '%f[%S][%l%d]+%f[^%l%d]', '%f[%P][%l%d]+%f[^%l%d]', '^[%l%d]+%f[^%l%d]' },
                        '^().*()$',
                    },
                    g = Core.mini.ai_buffer, -- buffer
                    u = ai.gen_spec.function_call(), -- u for "Usage"
                    U = ai.gen_spec.function_call({ name_pattern = '[%w_]' }), -- without dot in function name
                },
            }
        end,
        config = function(_, opts)
            require('mini.ai').setup(opts)
            Core.schedule_on_load('which-key.nvim', function()
                Core.mini.ai_whichkey(opts)
            end)
        end,
    },
}
