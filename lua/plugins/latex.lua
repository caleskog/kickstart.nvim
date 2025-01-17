return {
    {
        'lervag/vimtex',
        enabled = false,
        lazy = false, -- we don't want to lazy load VimTeX
        -- tag = "v2.15", -- uncomment to pin to a specific release
        init = function()
            -- VimTeX configuration goes here, e.g.
            vim.g.vimtex_view_method = 'zathura'
            -- vim.g.vimtex_view_general_viewer = 'okular'
            -- vim.g.vimtex_view_general_options = '--unique file:@pdf\\#src:@line@tex'

            -- Local leader mappings
            -- vim.g.maplocalleader = '\\'

            -- Disable default mappings
            -- vim.g.vimtex_mappings_enabled = 0

            vim.g.vimtex_compiler_latexmk = {
                aux_dir = 'build',
                options = {
                    '-shell-escape',
                    '-file-line-error',
                    '-synctex=1',
                    '-interaction=nonstopmode',
                },
            }
        end,
        -- Don't work, must be placed in the init function
        -- keys = {
        --     -- See :help vimtex-default-mappings
        --     { 'n', '<leader>li', '<plug>(vimtex-info)', { noremap = false, desc = 'LaTeX Info' } },
        --     { 'n', '<leader>ll', '<plug>(vimtex-compile)', { noremap = false, desc = 'Compile LaTeX' } },
        --     { 'n', '<leader>lL', '<plug>(vimtex-log)', { noremap = false, desc = 'LaTeX Log' } },
        --     { 'n', '<leader>lv', '<plug>(vimtex-view)', { noremap = false, desc = 'View PDF' } },
        --     { 'n', '<leader>lq', '<plug>(vimtex-stop)', { noremap = false, desc = 'Stop compilation' } },
        --     { 'n', '<leader>lQ', '<plug>(vimtex-stop-all)', { noremap = false, desc = 'Stop all' } },
        --     { 'n', '<leader>lt', '<plug>(vimtex-toc-toggle)', { noremap = false, desc = 'Toggle ToC' } },
        --     { 'n', '<leader>lc', '<plug>(vimtex-clean)', { noremap = false, desc = 'Clean up' } },
        --     { 'n', '<leader>lC', '<plug>(vimtex-clean-full)', { noremap = false, desc = 'Full clean up' } },
        --     { 'n', '<leader>lr', '<plug>(vimtex-reverse-search)', { noremap = false, desc = 'Reverse search' } },
        --     { 'n', '<leader>lx', '<plug>(vimtex-reload)', { noremap = false, desc = 'Reload' } },
        --     { 'n', '<leader>lX', '<plug>(vimtex-reload)', { noremap = false, desc = 'Reload state' } },
        --     { 'n', '<leader>lm', '<plug>(vimtex-reload)', { noremap = false, desc = 'Toggle main' } },
        --     { 'n', '<leader>la', '<plug>(vimtex-reload)', { noremap = false, desc = 'Context menu' } },
        -- },
    },
}
