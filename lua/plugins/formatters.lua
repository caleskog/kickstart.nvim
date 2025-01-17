-- @author caleskog

return {
    {
        -- [[Autoformatting]]
        'stevearc/conform.nvim',
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local conform = require('conform')

            -- In normal mode it will apply to the whole file
            -- In visual mode it will apply to the selected text.
            Core.utils.keymap.fmap('nv', '<leader>cf', function()
                conform.format({
                    timeout_ms = 500,
                    lsp_fallback = 'fallback',
                })
            end, 'Format File')

            -- Setup conform
            conform.setup({
                notify_on_error = false,
                formatters = {
                    ['clang-fmt-pre'] = {
                        ---Replace all `#pragma omp ...` with `//#pragma omp ...`
                        format = function(self, ctx, lines, callback)
                            -- Use this variable if options should be possible
                            local _ = self.options
                            local format_erros = nil
                            local formatted_lines = vim.deepcopy(lines)
                            local pattern = '^%s*#pragma omp'
                            -- If a range is provided, only format that range
                            if ctx.range then
                                local row = ctx.range.start[1]
                                local end_row = ctx.range['end'][1]
                                for i = row, end_row do
                                    local line = lines[i]
                                    if line:match(pattern) then
                                        formatted_lines[i] = line:gsub(pattern, '//#pragma omp')
                                    end
                                end
                            else
                                for i, line in ipairs(lines) do
                                    if line:match(pattern) then
                                        -- vim.notify('ORG_LINE: »' .. line .. '«')
                                        local fmt_line = line:gsub(pattern, '//#pragma omp')
                                        -- vim.notify('FMT_LINE: »' .. fmt_line .. '«')
                                        formatted_lines[i] = fmt_line
                                    end
                                end
                            end
                            callback(format_erros, formatted_lines)
                        end,
                    },
                    ['clang-fmt-post'] = {
                        ---Replace all `//#pragma omp ...` with `#pragma omp ...`
                        format = function(self, ctx, lines, callback)
                            -- Use this variable if options should be possible
                            local _ = self.options
                            local format_erros = nil
                            local formatted_lines = vim.deepcopy(lines)
                            local pattern = '//%s#pragma omp'
                            -- If a range is provided, only format that range
                            if ctx.range then
                                local row = ctx.range.start[1]
                                local end_row = ctx.range['end'][1]
                                -- local col = ctx.range.start[2]
                                -- local end_col = ctx.range['end'][2]
                                for i = row, end_row do
                                    local line = lines[i]
                                    if line:match(pattern) then
                                        formatted_lines[i] = line:gsub(pattern, '#pragma omp')
                                    end
                                end
                            else
                                for i, line in ipairs(formatted_lines) do
                                    if line:match(pattern) then
                                        formatted_lines[i] = line:gsub(pattern, '#pragma omp')
                                    end
                                end
                            end
                            callback(format_erros, formatted_lines)
                        end,
                    },
                },
                formatters_by_ft = {
                    lua = { 'stylua' },
                    bashls = { 'shfmt' },
                    c = { 'clang-format' },
                    cpp = { 'cppcheck', 'clang-fmt-pre', 'clang-format', 'clang-fmt-post' },
                    -- asm = { 'asmfmt' }, -- Disabled due to being specific to GO assembly rather than general assembly
                    cmake = { 'cmakelang' },
                    go = { 'gofumpt', 'goimports-reviser' },
                    -- Conform can also run multiple formatters sequentially
                    -- python = { "isort", "black" },
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
                    -- Preprocess the code if it's a C/C++ file
                    -- if vim.bo[bufnr].filetype == 'c' or vim.bo[bufnr].filetype == 'cpp' then
                    -- end
                    return {
                        timeout_ms = 500,
                        lsp_fallback = 'fallback',
                    }
                end,
            })
        end,
    },
}
