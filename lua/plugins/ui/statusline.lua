return {
    {
        'echasnovski/mini.statusline',
        event = 'VimEnter',
        opts = {
            use_icons = vim.g.have_nerd_font,
        },
        config = function(opts)
            local statusline = require('mini.statusline')
            statusline.setup(opts)
            -- set the section for cursor location to LINE:COLUMN
            ---@diagnostic disable-next-line: duplicate-set-field
            statusline.section_location = function()
                return '%2l:%-2v'
            end
        end,
    },
}
