-- File: plugins/mini.lua
-- Author: caleskog
-- Description: Usefull plugins/modules for improving overall Neovim experience.
local util = require('../util')

local function which_key_spec(mode)
    local desc_t = {
        util.WhichKey_ai(mode, '[a]rgument/parameter'),
        util.WhichKey_ai(mode, '[f]unction call'),
        util.WhichKey_ai(mode, '[F]unction'),
        util.WhichKey_ai(mode, '[c]onditional'),
        util.WhichKey_ai(mode, '[C]lass'),
        util.WhichKey_ai(mode, '[S]tatement'),
        util.WhichKey_ai(mode, '[L]oop'),
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
    }
    if util.module_mxists('nvim-treesitter-textobjects') then
        local spec_treesitter = require('mini.ai').gen_spec.treesitter
        setup_tlb['custom_textobjects'] = {
            a = spec_treesitter({ a = '@parameter.outer', i = '@parameter.inner' }),
            f = spec_treesitter({ a = '@call.outer', i = '@call.inner' }),
            F = spec_treesitter({ a = '@function.outer', i = '@function.inner' }),
            c = spec_treesitter({ a = '@conditional.outer', i = '@conditional.inner' }),
            C = spec_treesitter({ a = '@class.outer', i = '@class.inner' }),
            S = spec_treesitter({ a = '@statement.outer', i = '@statement.inner' }),
            L = spec_treesitter({ a = '@loop.outer', i = '@loop.inner' }),
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
    { -- Collection of various small independent plugins/modules
        'echasnovski/mini.nvim',
        version = '*',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        config = function()
            mini_ai()
            -- Add/delete/replace surroundings (brackets, quotes, etc.)
            --
            -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
            -- - sd'   - [S]urround [D]elete [']quotes
            -- - sr)'  - [S]urround [R]eplace [)] [']
            require('mini.surround').setup()

            -- Simple and easy statusline.
            --  You could remove this setup call if you don't like it,
            --  and try some other statusline plugin
            local statusline = require('mini.statusline')
            -- set use_icons to true if you have a Nerd Font
            statusline.setup({ use_icons = vim.g.have_nerd_font })

            -- You can configure sections in the statusline by overriding their
            -- default behavior. For example, here we set the section for
            -- cursor location to LINE:COLUMN
            ---@diagnostic disable-next-line: duplicate-set-field
            statusline.section_location = function()
                return '%2l:%-2v'
            end

            -- ... and there is more!
            --  Check out: https://github.com/echasnovski/mini.nvim
        end,
    },
}
