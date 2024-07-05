-- File: plugin/terminal.lua
-- Author: caleskog
-- Description: Terminal configurations.

-- local set = vim.opt_local
--
-- -- Set local settings for terminal buffers
-- vim.api.nvim_create_autocmd('TermOpen', {
--     group = vim.api.nvim_create_augroup('custom-term-open', {}),
--     callback = function()
--         set.number = false
--         set.relativenumber = false
--         set.scrolloff = 0
--     end,
-- })
--
-- -- Esily hit escape in terminal mode
-- vim.keymap.set('t', '<ESC><ESC>', '<C-\\><C-n>', { desc = 'Exit Terminal' })
--
-- -- Open a terminal at the bottom of the screen with a fixed heigh.
-- vim.keymap.set('n', '<leader>t', function()
--     vim.cmd.new()
--     vim.cmd.wincmd('j')
--     vim.api.nvim_win_set_height(0, 12)
--     vim.wo.winfixheight = true
--     vim.cmd.term()
-- end, { desc = 'Open [T]erminal' })

return {
    {
        'akinsho/toggleterm.nvim',
        version = '*',
        config = true,
        opts = {
            open_mapping = [[<C-\>]],
            terminal_mapping = true,
            auto_scroll = true,
            direction = 'float',
        },
    },
}
