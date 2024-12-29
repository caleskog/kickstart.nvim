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
        -- Snippet Engine
        'L3MON4D3/LuaSnip',
        event = 'InsertEnter',
        dependencies = {
            -- Premade snippets for many languages (https://github.com/rafamadriz/friendly-snippets)
            'rafamadriz/friendly-snippets',
        },
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
                    ['<C-f>'] = nil,
                    ['<C-b>'] = nil,
                }),
                sources = {
                    { name = 'lazydev', group_index = 0 }, -- lower group_index = higher priority
                    { name = 'copilot' },
                    { name = 'nvim_lsp' },
                    { name = 'path' },
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
    -- Snippets
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'L3MON4D3/LuaSnip', -- Snippet Engine
            'saadparwaiz1/cmp_luasnip', -- nvim-cmp sources
        },
        opts = function(_, opts)
            local luasnip = require('luasnip')
            require('luasnip.loaders.from_vscode').lazy_load()
            luasnip.filetype_extend('cpp', { 'unreal', 'cppdoc' })
            luasnip.filetype_extend('c', { 'cdoc' })
            luasnip.filetype_extend('lua', { 'luadoc' })
            luasnip.filetype_extend('rust', { 'rustdoc' })

            opts.snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            }
            if Core.has('LuaSnip') then
                local cmp = require('cmp')
                table.insert(opts.mapping, {
                    ['<C-f>'] = cmp.mapping(function()
                        if luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        end
                    end, { 'i', 's' }),
                    ['<C-b>'] = cmp.mapping(function()
                        if luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        end
                    end, { 'i', 's' }),
                })
                if Core.has('cmp_luasnip') then
                    table.insert(opts.sources, { name = 'luasnip' })
                end
            end
            -- if Core.has('nvim-snippets') then
            --     table.insert(opts.sources, { name = 'snippets' })
            -- end
        end,
    },
}
