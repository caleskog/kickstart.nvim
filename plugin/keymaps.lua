-- File: keymaps.lua
-- Author: caleskog
-- Description: A compainion script for 'init.lua' that hosts all keybindings and keymaps.
-- HELP: :help vim.keymaps.set()

local util = require('util')

-- As highlight on search is set in `options.lua`, but clear on pressing <Esc> in normal mode
util.cmap('n', '<Esc>', 'nohlsearch')

-- Allow navigating wrapped lines like physical lines
util.emap('nv', 'j', "v:count ? 'j' : 'gj'")
util.emap('nv', 'k', "v:count ? 'k' : 'gk'")

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
