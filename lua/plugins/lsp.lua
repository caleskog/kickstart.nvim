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

            -- [[Autoformatting]]
            { 'stevearc/conform.nvim' },

            -- A bunch of schema informations for jsonls and yamlls
            { 'b0o/SchemaStore.nvim' },
        },
        config = function()
            -- Brief aside: **What is LSP?**
            --
            -- LSP is an initialism you've probably heard, but might not understand what it is.
            --
            -- LSP stands for Language Server Protocol. It's a protocol that helps editors
            -- and language tooling communicate in a standardized fashion.
            --
            -- In general, you have a "server" which is some tool built to understand a particular
            -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
            -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
            -- processes that communicate with some "client" - in this case, Neovim!
            --
            -- LSP provides Neovim with features like:
            --  - Go to definition
            --  - Find references
            --  - Autocompletion
            --  - Symbol Search
            --  - and more!
            --
            -- Thus, Language Servers are external tools that must be installed separately from
            -- Neovim. This is where `mason` and related plugins come into play.
            --
            -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
            -- and elegantly composed help section, `:help lsp-vs-treesitter`
            local util = require('../util')

            local capabilities = nil
            -- Add extended capabilities to lspconfig
            if pcall(require, 'cmp_nvim_lsp') then
                capabilities = require('cmp_nvim_lsp').default_capabilities()
                -- Ensure that dynamicRegistration is enabled! (for `markdown_oxide`)
                capabilities.workspace = {
                    didChangeWatchedFiles = {
                        dynamicRegistration = true,
                    },
                }
            end

            -- Require it here in the case of usage in lsp servers configurations.
            local lspconfig = require('lspconfig')

            -- Enable the following language servers
            --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
            --
            --  Add any additional override configuration in the following tables. Available keys are:
            --  - cmd (table): Override the default command used to start the server
            --  - filetypes (table): Override the default list of associated filetypes for the server
            --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
            --  - settings (table): Override the default settings passed when initializing the server.
            --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
            --  HELP: See `:help lspconfig-all` for a list of all the pre-configured LSPs.
            --  Some languages (like typescript) have entire language plugins that can be useful: https://github.com/pmizio/typescript-tools.nvim
            --  But for many setups, the LSP (`tsserver`) will work just fine
            local servers = {
                clangd = {
                    cmd = { 'clangd', '--offset-encoding=utf-16' },
                    filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
                },
                pyright = true,
                rust_analyzer = true,
                asm_lsp = true,
                bashls = true,
                markdown_oxide = true,
                marksman = true,
                cmake = true,

                jsonls = {
                    settings = {
                        json = {
                            schemas = require('schemastore').json.schemas(),
                            validate = { enable = true },
                        },
                    },
                },

                yamlls = {
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

                lua_ls = {
                    -- cmd = {...},
                    -- filetypes = { ...},
                    -- capabilities = {},
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

            -- Ensure the servers and tools above are installed, and add other tools that Mason will install for you
            --  To check the current status of installed tools and/or manually install
            --  other tools, you can run
            --    :Mason
            --
            --  You can press `g?` for help in this menu.
            require('mason').setup()
            local ensure_installed = {
                'stylua',
                'lua_ls',
                'clang-format',
                'asmfmt',
                'cmakelang',
                'codelldb',
            }

            vim.list_extend(ensure_installed, servers_to_install)
            require('mason-tool-installer').setup({ ensure_installed = ensure_installed })

            -- LSP servers and clients are able to communicate to each other what features they support.
            --  By default, Neovim doesn't support everything that is in the LSP specification.
            --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
            --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
            local client_capabilities = vim.lsp.protocol.make_client_capabilities()
            for name, config in pairs(servers) do
                if config == true then
                    config = {}
                end
                config = vim.tbl_deep_extend('force', client_capabilities, {
                    capabilities = capabilities,
                }, config)

                -- TODO: Might need to ensure `markdown_oxide` is on attach config
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
                    --  This is where a variable was first declared, or where a function is defined, etc.
                    --  To jump back, press <C-t>.
                    map('gd', require('telescope.builtin').lsp_definitions, 'Goto Definition')

                    -- Find references for the word under your cursor.
                    map('gr', require('telescope.builtin').lsp_references, 'Goto References')

                    -- Jump to the implementation of the word under your cursor.
                    --  Useful when your language has ways of declaring types without an actual implementation.
                    map('gI', require('telescope.builtin').lsp_implementations, 'Goto Implementation')

                    -- Jump to the type of the word under your cursor.
                    --  Useful when you're not sure what type a variable is and you want to see
                    --  the definition of its *type*, not where it was *defined*.
                    map('gy', require('telescope.builtin').lsp_type_definitions, 'Goto Type Definition')

                    -- Fuzzy find all the symbols in your current document.
                    --  Symbols are things like variables, functions, types, etc.
                    map('<leader>cs', require('telescope.builtin').lsp_document_symbols, 'Document Symbols')

                    -- Fuzzy find all the symbols in your current workspace.
                    --  Similar to document symbols, except searches over your entire project.
                    map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace Symbols')

                    -- Rename the variable under your cursor.
                    --  Most Language Servers support renaming across files, etc.
                    map('<leader>r', vim.lsp.buf.rename, 'Rename')

                    -- Execute a code action, usually your cursor needs to be on top of an error
                    -- or a suggestion from your LSP for this to activate.
                    map('<leader>a', vim.lsp.buf.code_action, 'Code Action')

                    -- Opens a popup that displays documentation about the word under your cursor
                    --  See `:help K` for why this keymap.
                    map('K', vim.lsp.buf.hover, 'Hover Documentation')

                    map('gD', vim.lsp.buf.declaration, 'Goto Declaration')

                    -- The following two autocommands are used to highlight references of the
                    -- word under your cursor when your cursor rests there for a little while.
                    --    See `:help CursorHold` for information about when this is executed
                    --
                    -- When you move your cursor, the highlights will be cleared (the second autocommand).
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client.server_capabilities.documentHighlightProvider then
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = event.buf,
                            callback = vim.lsp.buf.clear_references,
                        })
                    end

                    -- Refresh codelens on TextChanged and InsertLeave as well (Markdow Oxide)
                    if client and client.server_capabilities.codeLensProvider then
                        vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave', 'CursorHold', 'LspAttach', 'BufEnter' }, {
                            buffer = event.buf,
                            callback = function()
                                vim.lsp.codelens.refresh({ bufnr = 0 })
                            end,
                        })
                    end
                end,
            })

            -- [[Autoformatting Setup]]
            local conform = require('conform')
            conform.setup({
                notify_on_error = false,
                formatters_by_ft = {
                    lua = { 'stylua' },
                    bashls = { 'shfmt' },
                    c = { 'clang-format' },
                    cpp = { 'clang-format', 'cppcheck' },
                    asm = { 'asmfmt' },
                    cmake = { 'cmakelang' },
                    -- Conform can also run multiple formatters sequentially
                    -- python = { "isort", "black" },
                    --
                    -- You can use a sub-list to tell conform to run *until* a formatter
                    -- is found.
                    -- javascript = { { "prettierd", "prettier" } },
                },
                format_on_save = function(bufnr)
                    -- Don't autoformat on these filetypes
                    local ignore_filetypes = { 'txt', 'md' }
                    if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
                        return
                    end
                    -- Don't format premake5.lua files
                    local bufname = vim.api.nvim_buf_get_name(bufnr)
                    if bufname:match('premake5.lua$') then
                        return
                    end
                    return {
                        timeout_ms = 500,
                        lsp_fallback = 'fallback',
                    }
                end,
            })

            -- In normal mode it will apply to the whole file and in visual mode it will apply to the selected text.
            util.fmap('nv', '<leader>cf', function()
                conform.format({
                    timeout_ms = 500,
                    lsp_fallback = 'fallback',
                })
            end, 'Format File')
        end,
    },
}
