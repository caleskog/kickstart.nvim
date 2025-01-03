-- File: plugins/completion.lua
-- Author: caleskog
-- Description: Plugins for autocompletion.

return {
    {
        -- GitHub Copilot
        'zbirenbaum/copilot.lua',
        cmd = 'Copilot',
        event = 'LazyFile',
        config = function()
            require('copilot').setup({
                suggestion = { enabled = false },
                panel = { enabled = false },
            })
        end,
    },
    {
        -- nvim-cmp source for Copilot
        'zbirenbaum/copilot-cmp',
        event = 'InsertEnter',
        dependencies = {
            'zbirenbaum/copilot.lua',
        },
        config = function()
            require('copilot_cmp').setup()
        end,
    },
    {
        -- VSCode-like pictograms
        'onsails/lspkind.nvim',
        config = function()
            local lspkind = require('lspkind')
            lspkind.init({
                symbol_map = {
                    Copilot = '', -- Not default
                },
            })
            vim.api.nvim_set_hl(0, 'CmpItemKindCopilot', { fg = '#6CC644' })
        end,
    },
    {
        'folke/lazydev.nvim',
        ft = 'lua',
        cmd = 'LazyDev',
        ---@module 'lazydev'
        ---@type lazydev.Config
        opts = {
            library = {
                -- Load luvit types when the `vim.uv` word is found
                { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
                { path = 'snacks.nvim', words = { 'Snacks' } },
            },
        },
    },
    -- Setup nvim-cmp
    {
        'hrsh7th/nvim-cmp',
        version = false, -- According to LazyVim is the last release way too old
        event = 'InsertEnter',
        dependencies = {
            -- nvim-cmp sources
            'hrsh7th/cmp-nvim-lsp', -- nvim-lsp
            'hrsh7th/cmp-path', -- file/folder paths
            -- 'hrsh7th/cmp-buffer', -- buffer
            'hrsh7th/cmp-nvim-lsp-signature-help', -- signature help
            -- Visual enhancements
            'onsails/lspkind.nvim',
        },
        opts = function()
            vim.api.nvim_set_hl(0, 'CAleskogCmpGhostText', { link = 'Comment', default = true })
            local cmp = require('cmp')
            local defaults = require('cmp.config.default')()
            local lspkind = require('lspkind')

            return {
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                -- NOTE: See `:help ins-completion` to understand why these kyemaps are chosen.
                mapping = cmp.mapping.preset.insert({
                    ['<C-n>'] = cmp.mapping.select_next_item(), -- Select the [n]ext item
                    ['<C-p>'] = cmp.mapping.select_prev_item(), -- Select the [p]revious item
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Scrolls documentation [u]p
                    ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Scrolls documentation [d]own
                    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<C-Space>'] = cmp.mapping.complete({}), -- Manually trigger a completion from nvim-cmp.
                }),
                sources = {
                    { name = 'lazydev', group_index = 0 }, -- lower group_index = higher priority
                    { name = 'copilot' },
                    { name = 'nvim_lsp' },
                    { name = 'path' },
                    -- { name = 'buffer' },
                    { name = 'nvim_lsp_signature_helper' },
                    { name = 'render-markdown' },
                },
                ---@diagnostic disable-next-line: missing-fields
                formatting = {
                    format = lspkind.cmp_format({
                        mode = 'symbol_text', -- Symbol first, then text
                        maxwidth = 50,
                        ellipsis_char = '…',
                    }),
                },
                experimental = {
                    -- only show ghost text when we show ai completions
                    ghost_text = vim.g.ai_cmp and {
                        hl_group = 'CAleskogCmpGhostText',
                    } or false,
                },
                sorting = defaults.sorting,
            }
        end,
    },
    -- Snippet Engine
    {
        'L3MON4D3/LuaSnip',
        event = 'InsertEnter',
        dependencies = {
            'saadparwaiz1/cmp_luasnip', -- nvim-cmp sources
            'rafamadriz/friendly-snippets', -- Premade snippets for many languages
        },
        opts = {
            keep_roots = true,
            link_roots = true,
            link_children = true,

            update_events = 'TextChanged,TextChangedI',
            -- Remove snippets when text is changed, useful when `history` is enabled.
            delete_check_events = 'TextChanged',

            enable_autosnippets = true,
        },
        config = function(_, opts)
            local ls = require('luasnip')
            local types = require('luasnip.util.types')
            opts.ext_opts = {
                [types.choiceNode] = {
                    active = {
                        virt_text = { { '', 'Error' } }, --- TODO: Does this work?
                    },
                },
            }

            ls.setup(opts)

            require('luasnip.loaders.from_vscode').lazy_load()
            ls.filetype_extend('cpp', { 'unreal', 'cppdoc' })
            ls.filetype_extend('c', { 'cdoc' })
            ls.filetype_extend('lua', { 'luadoc' })
            ls.filetype_extend('rust', { 'rustdoc' })

            -- Load custom snippets (`paths` can be skipped as the
            -- snippets are in the default path, `~/.config/nvim/luasnippets`)
            require('luasnip.loaders.from_lua').lazy_load()
        end,
    },
    -- Snippets
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'L3MON4D3/LuaSnip', -- Snippet Engine
        },
        opts = function(_, opts)
            local ls = require('luasnip')

            opts.snippet = {
                expand = function(args)
                    ls.lsp_expand(args.body)
                end,
            }
            if Core.has('LuaSnip') and Core.has('cmp_luasnip') then
                -- Add nvim-cmp source for luasnip
                table.insert(opts.sources, { name = 'luasnip' })
                -- Add keymaps for luasnip
                local cmp = require('cmp')
                opts.mapping = Core.cmp.merge_keymaps(opts.mapping, {
                    ['<C-f>'] = cmp.mapping(function()
                        if ls.expand_or_locally_jumpable() then
                            ls.expand_or_jump()
                        end
                    end, { 'i', 's' }),
                    ['<C-b>'] = cmp.mapping(function()
                        if ls.locally_jumpable(-1) then
                            ls.jump(-1)
                        end
                    end, { 'i', 's' }),
                    ['<C-t>'] = cmp.mapping(function() -- Selecting within a list of options
                        if ls.choice_active() then
                            ls.change_choice(1)
                        end
                    end, { 'i' }),
                    ['<C-l>'] = cmp.mapping(function() -- Selecting within a list of options
                        require('luasnip.extras.select_choice')()
                    end, { 'i' }),
                })
            end
        end,
    },
}
