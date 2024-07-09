return {
    -- 'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
    -- { -- Add indentation guides even on blank lines
    --     'lukas-reineke/indent-blankline.nvim',
    --     -- Enable `lukas-reineke/indent-blankline.nvim`
    --     -- See `:help ibl`
    --     main = 'ibl',
    --     opts = {},
    --     config = function()
    --         require('ibl').setup()
    --     end,
    -- },
    {
        'NMAC427/guess-indent.nvim',
        config = function()
            require('guess-indent').setup({
                on_tab_options = { -- A table of vim options when tabs are detected
                    ['expandtab'] = false,
                },
                on_space_options = { -- A table of vim options when spaces are detected
                    ['expandtab'] = true,
                    ['tabstop'] = 'detected', -- If the option value is 'detected', The value is set to the automatically detected indent size.
                    ['softtabstop'] = 'detected',
                    ['shiftwidth'] = 'detected',
                },
            })
        end,
    },
}
