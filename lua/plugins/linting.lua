---@author caleskog (christoffer.aleskog@gmail.com)
---@file stow.d/.config/nvim/lua/plugins/linting.lua
---@description Linting things

return {
    {
        'mfussenegger/nvim-lint',
        event = 'LazyFile',
        opts = {
            events = { 'BufWritePost', 'BufReadPost', 'InsertLeave' },
            linters_by_ft = {
                dockerfile = { 'hadolint' },
                c = { 'clang-tidy' },
                cpp = { 'clangtidy' },
            },
        },
        config = function(_, opts)
            local lint = require('lint')

            lint.linters_by_ft = opts.linters_by_ft

            vim.api.nvim_create_autocmd(opts.events, {
                group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
                callback = function()
                    lint.try_lint()
                end,
            })
        end,
        keys = {
            {
                '<leader>l',
                function()
                    local lint = require('lint')
                    lint.try_lint()
                end,
                desc = 'Trigger linting for current file',
            },
        },
    },
}
