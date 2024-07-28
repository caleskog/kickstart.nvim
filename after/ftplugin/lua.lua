-- Function to get and modify highlight group settings
local function set_no_bg_for_string()
    -- Helper function to set background to transparent
    local function set_transparent_bg(hl)
        hl.bg = 'none' -- Use 'none' for transparent background
        return hl
    end

    -- Modify highlight groups
    local highlight_groups = {
        'String',
        '@string',
        '@string.regex',
        '@string.escape',
        '@string.special',
    }

    for _, group in ipairs(highlight_groups) do
        local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
        vim.api.nvim_set_hl(0, group, set_transparent_bg(hl))
    end
end

-- Function to disable cursor line highlighting
local function disable_cursor_line()
    vim.api.nvim_set_hl(0, 'CursorLine', { bg = 'none' })
end

--- Disable highlighting for multiline strings
-- set_no_bg_for_string()
--- Disable cursor line highlighting
-- disable_cursor_line()

--- Set up Premake autocompletion
local cmp_premake = require('cmp/sources/premake5')
cmp_premake.setup()
