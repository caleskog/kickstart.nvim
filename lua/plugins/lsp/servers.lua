local lspconfig = require('lspconfig')

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
        cmd = { 'clangd', '--offset-encoding=utf-16', '--compile-commands-dir=./build/' },
        filetypes = { 'c', 'c.in', 'cpp', 'cpp.in', 'h', 'h.in', 'hpp', 'hpp.in', 'hh', 'hh.in', 'objc', 'objcpp' },
        root_dir = lspconfig.util.root_pattern('compile_commands.json', 'compile_flags.txt', '.git'),
        -- root_dir = lspconfig.util.root_pattern('compile_commands.json', 'compile_flags.txt', '.git'),
        --[[ on_attach = function(_, bufnr)
            -- Check if the current filename ends with '.m4.cpp' (e.g. main.m4.cpp would be .m4.cpp)
            local m4_path = vim.fn.expand('%:p')
            gprint('m4_path: ' .. m4_path)
            if m4_path:match('%.m4%.cpp$') then
                -- Get current working directory
                local cwd = vim.fn.getcwd()
                gprint('cwd: ' .. cwd)
                -- <cwd> .. "/build/" .. <filename-without-extension> .. ".cpp"
                local comdined_path = cwd .. '/build/gen/' .. vim.fn.expand('%:t:r:r') .. '.cpp'
                local furi = vim.uri_from_fname(comdined_path)
                gprint('comdined_path: ' .. comdined_path)
                gprint('furi: ' .. furi)
                vim.lsp.buf_notify(bufnr, 'textDocument/didOpen', {
                    uri = furi,
                    languageId = 'cpp',
                    version = 1,
                    text = vim.fn.readfile(comdined_path),
                })
            end
        end, ]]
    },
    texlab = {},
    pyright = {},
    rust_analyzer = {},
    asm_lsp = {
        cmd = { 'asm-lsp' },
        filetypes = { 'asm', 's', 'S' },
    },
    bashls = {},
    -- markdown_oxide = true,
    marksman = {},
    cmake = {}, -- CMake LSP
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

return servers
