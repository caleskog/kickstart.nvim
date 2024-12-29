-- File: plugins/lsp.lua
-- Author: caleskog
-- Description: LSP configuration.

return {
    { -- LSP Configuration & Plugins
        'neovim/nvim-lspconfig',
        event = 'LazyFile',
        dependencies = {
            -- Automatically install LSPs and related tools to stdpath for Neovim
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'WhoIsSethDaniel/mason-tool-installer.nvim',

            -- Useful status updates for LSP.
            --  NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            { 'j-hui/fidget.nvim', opts = {} },

            -- A bunch of schema informations for jsonls and yamlls
            { 'b0o/SchemaStore.nvim' },
        },
        config = function()
            local lspconfig = require('lspconfig')

            -- Capabilities for LSP servers
            local capabilities = vim.lsp.protocol.make_client_capabilities()

            -- Extra capabilities for LSP servers
            local ok, cmp = pcall(require, 'cmp_nvim_lsp')
            if ok then
                capabilities = vim.tbl_deep_extend('force', capabilities, cmp.default_capabilities())
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
                    local bnmap = function(keys, func, desc)
                        Core.utils.keymap.bmap(event.buf, 'n', keys, func, 'LSP: ' .. desc)
                    end

                    -- Jump to the definition of the word under your cursor.
                    bnmap('gd', require('telescope.builtin').lsp_definitions, 'Goto Definition')
                    bnmap('gr', require('telescope.builtin').lsp_references, 'Goto References')
                    bnmap('gI', require('telescope.builtin').lsp_implementations, 'Goto Implementation')
                    bnmap('gy', require('telescope.builtin').lsp_type_definitions, 'Goto Type Definition')
                    bnmap('<leader>cs', require('telescope.builtin').lsp_document_symbols, 'Document Symbols')
                    bnmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace Symbols')
                    bnmap('<leader>r', vim.lsp.buf.rename, 'Rename')
                    bnmap('<leader>a', vim.lsp.buf.code_action, 'Code Action')
                    bnmap('K', vim.lsp.buf.hover, 'Hover Documentation')
                    bnmap('gD', vim.lsp.buf.declaration, 'Goto Declaration')

                    -- Client
                    local client = vim.lsp.get_client_by_id(event.data.client_id)

                    -- Highlight references of the word under your cursor after hover for a little while.
                    Core.autocmd.lsp_highlight(client, event, 'caleskog-lsp-highlight', 'caleskog-lsp-detach')

                    -- The following code creates a keymap to toggle inlay hints in the code,
                    -- if the language server supports them (e.g. rust)
                    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                        local filter = { bufnr = event.buf } ---@type vim.lsp.inlay_hint.enable.Filter
                        Core.snacks
                            .btoggle({
                                bufnr = event.buf,
                                name = 'LSP Inlay Hints',
                                get = function()
                                    return vim.lsp.inlay_hint.is_enabled(filter)
                                end,
                                set = function(_)
                                    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
                                end,
                            })
                            :map('<leader>th', { buffer = event.buf })
                    end
                end,
            })
        end,
    },
}
