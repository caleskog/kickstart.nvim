-- File: lua/custom/plugins/autopairs.lua

return {
    'windwp/nvim-autopairs',
    event = 'VeryLazy',
    -- Optional dependency
    dependencies = { 'hrsh7th/nvim-cmp' },
    opts = {
        enable_check_bracket_line = true,
        check_ts = true,
    },
    config = function(opts)
        require('nvim-autopairs').setup(opts)

        -- If you want to automatically add '(' after selecting a function or method
        if Core.has('cmp') then
            local cmp_autopair = require('nvim-autopairs.completion.cmp')
            Core.schedule_on_load('cmp', function()
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
            end)
        end
    end,
}
