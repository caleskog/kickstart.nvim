-- File: lua/custom/plugins/autopairs.lua

return {
    'windwp/nvim-autopairs',
    event = 'VeryLazy',
    -- Optional dependency
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
        require('nvim-autopairs').setup({
            enable_check_bracket_line = true,
            check_ts = true,
        })
        -- If you want to automatically add '(' after selecting a function or method
        local cmp_autopair = require('nvim-autopairs.completion.cmp')
        local cmp = require('cmp')
        cmp.event:on(
            'confirm_done',
            cmp_autopair.on_confirm_done({
                filetypes = {
                    markdown = false, -- Disable for markdown files
                    tex = false, -- Disable for TeX files
                },
            })
        )
    end,
}
