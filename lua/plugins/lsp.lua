-- File: plugins/lsp.lua
-- Author: caleskog
-- Description: LSP configuration.

return {
    { -- LSP Configuration & Plugins
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Automatically install LSPs and related tools to stdpath for Neovim
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'WhoIsSethDaniel/mason-tool-installer.nvim',

            -- Useful status updates for LSP.
            --  NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            { 'j-hui/fidget.nvim', opts = {} },

            -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
            -- used for completion, annotations and signatures of Neovim apis
            { 'folke/neodev.nvim', opts = {} },

            -- A bunch of schema informations for jsonls and yamlls
            { 'b0o/SchemaStore.nvim' },
        },
        config = function()
            local util = require('util')
            local lspconfig = require('lspconfig')

            -- Capabilities for LSP servers
            local capabilities = vim.lsp.protocol.make_client_capabilities()

            -- Extra capabilities for LSP servers
            local ok, cmp = pcall(require, 'cmp_nvim_lsp')
            if ok then
                capabilities = vim.tbl_deep_extend('force', capabilities, cmp.default_capabilities())
                -- -- Ensure that dynamicRegistration is enabled! (for `markdown_oxide`)
                -- capabilities.workspace = {
                --     didChangeWatchedFiles = {
                --         dynamicRegistration = true,
                --     },
                -- }
            end

            -- LSP servers to install
            local servers = require('plugins.lsp.servers')

            -- Tools to install
            local tools = require('plugins.lsp.tools')
            tools = vim.list_extend(vim.tbl_keys(servers or {}), tools)

            -- Ensure the servers and tools above are installed
            require('mason').setup()
            require('mason-tool-installer').setup({ ensure_installed = tools })

            --  Tell the LSP servers what new capabilities are available.
            require('mason-lspconfig').setup({
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                        lspconfig[server_name].setup(server)
                    end,
                },
            })

            --  This function gets run when an LSP attaches to a particular buffer.
            --    That is to say, every time a new file is opened that is associated with
            --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
            --    function will be executed to configure the current buffer
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('caleskog-lsp-attach', { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc)
                        util.map('n', keys, func, 'LSP: ' .. desc, { buffer = event.buf })
                    end

                    -- Jump to the definition of the word under your cursor.
                    map('gd', require('telescope.builtin').lsp_definitions, 'Goto Definition')
                    map('gr', require('telescope.builtin').lsp_references, 'Goto References')
                    map('gI', require('telescope.builtin').lsp_implementations, 'Goto Implementation')
                    map('gy', require('telescope.builtin').lsp_type_definitions, 'Goto Type Definition')
                    map('<leader>cs', require('telescope.builtin').lsp_document_symbols, 'Document Symbols')
                    map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace Symbols')
                    map('<leader>r', vim.lsp.buf.rename, 'Rename')
                    map('<leader>a', vim.lsp.buf.code_action, 'Code Action')
                    map('K', vim.lsp.buf.hover, 'Hover Documentation')
                    map('gD', vim.lsp.buf.declaration, 'Goto Declaration')

                    local autocmd = require('cond_autocmd')
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    -- Highlight references of the word under your cursor after hover for a little while.
                    autocmd.lsp_highlight(client, event, 'caleskog-lsp-highlight', 'caleskog-lsp-detach')

                    -- -- Refresh codelens on TextChanged and InsertLeave as well (Markdow Oxide)
                    -- if client and client.server_capabilities.codeLensProvider then
                    --     vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave', 'CursorHold', 'LspAttach', 'BufEnter' }, {
                    --         buffer = event.buf,
                    --         callback = function()
                    --             vim.lsp.codelens.refresh({ bufnr = 0 })
                    --         end,
                    --     })
                    -- end

                    -- The following code creates a keymap to toggle inlay hints in your
                    -- code, if the language server you are using supports them (e.g. rust)
                    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                        map('<leader>th', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
                        end, '[T]oggle Inlay [H]ints')
                    end
                end,
            })
        end,
    },
}
