-- File: keymaps.lua
-- Author: caleskog
-- Description: A compainion script for 'init.lua' that hosts all keybindings and keymaps.
-- HELP: :help vim.keymaps.set()

---@diagnostic disable-next-line: different-requires
local util = require('util')

-- As highlight on search is set in `options.lua`, but clear on pressing <Esc> in normal mode
-- util.cmap('n', '<Esc>', 'nohlsearch') -- Disable due to issues with folke/flash.nvim
util.map('n', '<CR>', ':nohlsearch<CR>', 'Clear search highlights')

-- Allow navigating wrapped lines like physical lines
util.emap('nv', 'j', "v:count ? 'j' : 'gj'")
util.emap('nv', 'k', "v:count ? 'k' : 'gk'")

-- Allow navigating with arrow keys as they werer 'hjkl'
util.emap('nv', '<Up>', "v:count ? 'k' : 'gk'")
util.emap('nv', '<Down>', "v:count ? 'j' : 'gj'")
util.map('nv', '<Left>', 'h')
util.map('nv', '<Right>', 'l')

-- Source current file
util.map('n', '<leader><space>x', ':source %<CR>', 'Source current file')
-- Run current line (assumes Lua code)
util.map('n', '<leader>x', ':.lua<CR>', 'Lua: run line')
util.map('v', '<space>x', ':lua<CR>', 'Lua: run selection')

-- Diagnostic keymaps
util.map('n', '[d', vim.diagnostic.goto_prev, 'Go to previous Diagnostic message')
util.map('n', ']d', vim.diagnostic.goto_next, 'Go to next Diagnostic message')
util.map('n', '<leader>e', vim.diagnostic.open_float, 'Show diagnostic Error messages')
util.map('n', '<leader>q', vim.diagnostic.setloclist, 'Open diagnostic Quickfix list')

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
util.map('t', '<Esc><Esc>', '<C-\\><C-n>', 'Exit terminal mode')

-- Can only use this keybinding if `plenary` is loaded.
util.fmap('n', '<leader>o', function()
    if pcall(require, 'plenary') then
        util.open()
    else
        vim.ui.open(vim.api.nvim_buf_get_name(0))
    end
end, 'Open file w/ system default (possibly convert to HTML)')

-- Can only use this keybinding if `plenary` is loaded.
util.fmap('n', '<leader>pch', function()
    local name = vim.api.nvim_buf_get_name(0)
    if pcall(require, 'plenary') then
        util.convert(name, { 'markdown' }, '.html', true)
    else
        vim.notify('Install plenary.nvim for this feature', 'warn', { title = 'Missing plugin' })
    end
end, 'Convert file to HTML')

-- Buffer keymaps
util.map('n', '<leader>Bc', ':bd<CR>', 'Close current buffer')
util.map('n', '<leader>Bo', function()
    -- Can also use `:%bd|e#<CR>` to close all buffers except the current one
    local current = vim.api.nvim_get_current_buf()
    local buffers = vim.api.nvim_list_bufs()
    local strs = {}
    for _, buf in ipairs(buffers) do
        if buf ~= current and vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_name(buf) ~= '' then
            -- Remove prorect dir from buffer name
            local name = vim.api.nvim_buf_get_name(buf)
            name = name:gsub(vim.fn.getcwd() .. '/', '')
            -- Set up buffer object
            local b = { id = buf, name = name }
            strs[#strs + 1] = 'Closing buffer ' .. b.name .. '[' .. b.id .. ']'
            -- Close buffer
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end
    -- Notify user of closed buffers
    vim.notify(table.concat(strs, '\n'), 'info', { title = 'Closed buffers' })
end, 'Close other buffers')
util.map('n', '<leader>Ba', ':%bd<CR>', 'Close all buffers')
util.map('n', '<leader>Bh', function()
    local buffers = vim.api.nvim_list_bufs()
    for _, buf in ipairs(buffers) do
        if vim.api.nvim_buf_get_name(buf) == '' then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end
end, 'Close nameless buffers')

-- NOTE: See lua/plugins/navigation.lua
--
--[[ -- Basic keybindings for moving focus to another window
-- HELP: See `:help wincmd` for a list of all window commands
util.map('n', '<C-h>', '<C-w><C-h>', 'Move focus to the left window')
util.map('n', '<C-l>', '<C-w><C-l>', 'Move focus to the right window')
util.map('n', '<C-j>', '<C-w><C-j>', 'Move focus to the lower window')
util.map('n', '<C-k>', '<C-w><C-k>', 'Move focus to the upper window')


-- These mappings control the size of splits (height/width)
-- `<M-,>` => Alt + `,`
-- `<M-.>` => Alt + `.`
util.map('n', '<A-l>', '<C-w>5<', 'Resize left')
util.map('n', '<A-h>', '<C-w>5>', 'Resize right')
util.map('n', '<A-k>', '<C-w>+', 'Resize up')
util.map('n', '<A-j>', '<C-w>-', 'Resize down') ]]
