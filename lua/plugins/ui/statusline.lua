return {
    {
        'echasnovski/mini.statusline',
        version = '*',
        event = 'VimEnter',
        opts = {
            use_icons = vim.g.have_nerd_font,
            content = {
                active = function()
                    local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
                    local git = MiniStatusline.section_git({ trunc_width = 40 })
                    local diff = MiniStatusline.section_diff({ trunc_width = 75 })
                    local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
                    local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
                    local filename = MiniStatusline.section_filename({ trunc_width = 140 })
                    local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
                    local location = '%2l:%-2v'
                    local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

                    local recording = ''
                    if Core.has('noice') then
                        ---@diagnostic disable-next-line: undefined-field
                        if require('noice').api.status.mode.has() then
                            recording = 'Recording'
                        end
                    end

                    return MiniStatusline.combine_groups({
                        { hl = mode_hl, strings = { mode } },
                        { hl = 'CAleskogStatuslineRecord', strings = { recording } },
                        { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics, lsp } },
                        '%<', -- Mark general truncate point
                        { hl = 'MiniStatuslineFilename', strings = { filename } },
                        '%=', -- End left alignment
                        { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
                        { hl = mode_hl, strings = { search, location } },
                    })
                end,
            },
        },
        config = function(_, opts)
            -- set highlight groups
            vim.api.nvim_set_hl(0, 'CAleskogStatuslineRecord', { bg = '#1d2021', fg = '#fbf1c7', bold = true })

            local statusline = require('mini.statusline')
            statusline.setup(opts)
        end,
    },
}
