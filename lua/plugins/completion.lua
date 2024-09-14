-- File: plugins/completion.lua
-- Author: caleskog
-- Description: Plugins for autocompletion.

return {
    {
        -- GitHub Copilot
        'zbirenbaum/copilot.lua',
        cmd = 'Copilot',
        event = 'InsertEnter',
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
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            -- Snippet Engine
            'L3MON4D3/LuaSnip',
            -- nvim-cmp sources
            'saadparwaiz1/cmp_luasnip', -- LuaSnip
            'hrsh7th/cmp-nvim-lsp', -- nvim-lsp
            'hrsh7th/cmp-path', -- file/folder paths
            'hrsh7th/cmp-nvim-lsp-signature-help', -- signature help
            -- Visual enhancements
            'onsails/lspkind.nvim',
        },
        config = function()
            local cmp = require('cmp')
            local lspkind = require('lspkind')
            local luasnip = require('luasnip')

            require('luasnip.loaders.from_vscode').lazy_load()
            require('luasnip').filetype_extend('cpp', { 'unreal', 'cppdoc' })
            require('luasnip').filetype_extend('c', { 'cdoc' })
            require('luasnip').filetype_extend('lua', { 'luadoc' })
            require('luasnip').filetype_extend('rust', { 'rustdoc' })

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                -- NOTE: See `:help ins-completion` to und understand why these kyemaps are chosen.
                mapping = cmp.mapping.preset.insert({
                    ['<C-n>'] = cmp.mapping.select_next_item(), -- Select the [n]ext item
                    ['<C-p>'] = cmp.mapping.select_prev_item(), -- Select the [p]revious item
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Scrolls documentation [u]p
                    ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Scrolls documentation [d]own
                    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<C-Space>'] = cmp.mapping.complete({}), -- Manually trigger a completion from nvim-cmp.
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
                    -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
                    --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
                }),
                sources = {
                    -- group_index is used to prioritize sources, lower index = higher priority
                    { name = 'copilot' },
                    {
                        name = 'nvim_lsp',
                        option = {
                            -- markdown_oxide is as lsp server for markdown (see lua/plugins/lsp.lua)
                            markdown_oxide = {
                                keyword_pattern = [[\(\k\| \|\/\|#\)\+]],
                            },
                        },
                    },
                    { name = 'luasnip' },
                    { name = 'path' },
                    { name = 'nvim_lsp_signature_helper' },
                },
                ---@diagnostic disable-next-line: missing-fields
                formatting = {
                    format = lspkind.cmp_format({
                        mode = 'symbol_text', -- Symbol first, then text
                        maxwidth = 50,
                        ellipsis_char = '…',
                        -- Don't know exactly what the following option do exactly.
                        -- show_menu_labelDetails = true, -- show labelDetails in menu. Disabled by default
                    }),
                },
            })
        end,
    },
}
