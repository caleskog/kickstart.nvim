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
            local util = require('../util')
            local lspconfig = require('lspconfig')

            -- Capabilities for LSP servers
            local capabilities = nil

            -- Extra capabilities for LSP servers
            if pcall(require, 'cmp_nvim_lsp') then
                capabilities = require('cmp_nvim_lsp').default_capabilities()
                -- -- Ensure that dynamicRegistration is enabled! (for `markdown_oxide`)
                -- capabilities.workspace = {
                --     didChangeWatchedFiles = {
                --         dynamicRegistration = true,
                --     },
                -- }
            end

            --  HELP: See `:help lspconfig-all` for a list of all the pre-configured LSPs.
            local servers = {
                gopls = { -- Go LSP
                    cmd = { 'gopls' },
                    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
                    root_dir = lspconfig.util.root_pattern('go.work', 'go.mod', '.git'),
                    settings = {
                        gopls = {
                            completeUnimported = true,
                            -- usePlaceholders = true,
                            analyses = {
                                unusedparams = true,
                                -- shadow = true,
                            },
                            -- staticcheck = true,
                        },
                    },
                },
                golangci_lint_ls = { -- Go Linter
                    cmd = { 'golangci-lint-langserver' },
                    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
                    root_dir = lspconfig.util.root_pattern('go.work', 'go.mod', '.git'),
                },
                clangd = {
                    cmd = { 'clangd', '--offset-encoding=utf-16' },
                    filetypes = { 'c', 'c.in', 'cpp', 'cpp.in', 'h', 'h.in', 'hpp', 'hpp.in', 'hh', 'hh.in', 'objc', 'objcpp' },
                    root_dir = lspconfig.util.root_pattern('compile_commands.json', 'compile_flags.txt', '.git'),
                },
                texlab = true,
                pyright = true,
                rust_analyzer = true,
                asm_lsp = {
                    cmd = { 'asm-lsp' },
                    filetypes = { 'asm', 's', 'S' },
                },
                bashls = true,
                -- markdown_oxide = true,
                marksman = true,
                cmake = true, -- CMake LSP
                jsonls = { -- JSON LSP
                    settings = {
                        json = {
                            schemas = require('schemastore').json.schemas(),
                            validate = { enable = true },
                        },
                    },
                },
                yamlls = { -- YAML LSP
                    settings = {
                        yaml = {
                            schemaStore = {
                                enable = false,
                                url = '',
                            },
                            schemas = require('schemastore').yaml.schemas(),
                        },
                    },
                },
                lua_ls = { -- Lua LSP
                    settings = {
                        Lua = {
                            completion = {
                                callSnippet = 'Replace',
                            },
                            diagnostics = {
                                -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                                -- disable = { 'missing-fields' }
                                globals = { 'vim', 'premake' },
                            },
                        },
                    },
                },
            }

            local servers_to_install = vim.tbl_filter(function(key)
                local t = servers[key]
                if type(t) == 'table' then
                    return not t.manual_install
                else
                    return t
                end
            end, vim.tbl_keys(servers))

            -- Other tools (not pre-configured) that Mason will install
            require('mason').setup()
            local ensure_installed = {
                -- 'asmfmt', -- Disabled due to GO assembly specific
                -- 'lua_ls', -- Already specified in 'servers_to_install'
                'stylua',
                'clang-format',
                'cmakelang', -- cmake-formatter
                'codelldb', -- C/C++ debugger
                'gofumpt', -- Go code formatter
                'goimports-reviser', -- Go code formatter
                'golangci-lint', -- Go linter
            }

            -- Ensure the servers and tools above are installed
            vim.list_extend(ensure_installed, servers_to_install)
            require('mason-tool-installer').setup({ ensure_installed = ensure_installed })

            --  Tell the LSP servers what new capabilities are available.
            local client_capabilities = vim.lsp.protocol.make_client_capabilities()
            for name, config in pairs(servers) do
                if config == true then
                    config = {}
                end
                config = vim.tbl_deep_extend('force', client_capabilities, {
                    capabilities = capabilities,
                }, config)

                lspconfig[name].setup(config)
            end

            --  This function gets run when an LSP attaches to a particular buffer.
            --    That is to say, every time a new file is opened that is associated with
            --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
            --    function will be executed to configure the current buffer
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('custom-lsp-attach', { clear = true }),
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

                    -- Highlight references of the word under your cursor after hover for a little while.
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client.server_capabilities.documentHighlightProvider then
                        -- See `:help CursorHold` for information about when this is executed
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            callback = function(_)
                                -- Use treesitter to check if cursor is on a string
                                local ts = require('nvim-treesitter.ts_utils')
                                local winnr = vim.api.nvim_get_current_win()
                                local node = ts.get_node_at_cursor(winnr)
                                -- If cursor is on a string, don't highlight references
                                local string_node_types = { 'string', 'string_literal', 'string_content' }
                                if node and vim.tbl_contains(string_node_types, node:type()) then
                                    return
                                end
                                vim.lsp.buf.document_highlight()
                            end,
                        })
                        -- When you move your cursor, the highlights will be cleared (the second autocommand).
                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = event.buf,
                            callback = vim.lsp.buf.clear_references,
                        })
                    end

                    -- -- Refresh codelens on TextChanged and InsertLeave as well (Markdow Oxide)
                    -- if client and client.server_capabilities.codeLensProvider then
                    --     vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave', 'CursorHold', 'LspAttach', 'BufEnter' }, {
                    --         buffer = event.buf,
                    --         callback = function()
                    --             vim.lsp.codelens.refresh({ bufnr = 0 })
                    --         end,
                    --     })
                    -- end
                end,
            })
        end,
    },
}
