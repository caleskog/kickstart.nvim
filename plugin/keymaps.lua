-- File: keymaps.lua
-- Author: caleskog
-- Description: A compainion script for 'init.lua' that hosts all keybindings and keymaps.
-- HELP: :help vim.keymaps.set()

local function map(mode, key, invoke, desc)
    desc = desc or ''
    vim.keymap.set(mode, key, invoke, { desc = desc })
end

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
map('n', '[d', vim.diagnostic.goto_prev, 'Go to previous [D]iagnostic message')
map('n', ']d', vim.diagnostic.goto_next, 'Go to next [D]iagnostic message')
map('n', '<leader>e', vim.diagnostic.open_float, 'Show diagnostic [E]rror messages')
map('n', '<leader>q', vim.diagnostic.setloclist, 'Open diagnostic [Q]uickfix list')

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
map('t', '<Esc><Esc>', '<C-\\><C-n>', 'Exit terminal mode')

-- Basic keybindings for moving focus to another window
-- HELP: See `:help wincmd` for a list of all window commands
map('n', '<C-h>', '<C-w><C-h>', 'Move focus to the left window')
map('n', '<C-l>', '<C-w><C-l>', 'Move focus to the right window')
map('n', '<C-j>', '<C-w><C-j>', 'Move focus to the lower window')
map('n', '<C-k>', '<C-w><C-k>', 'Move focus to the upper window')

-- These mappings control the size of splits (height/width)
-- `<M-,>` => Alt + `,`
-- `<M-.>` => Alt + `.`
map('n', '<M-,>', '<C-w>5<', 'Resize left')
map('n', '<M-.>', '<C-w>5>', 'Resize right')
map('n', '<M-u>', '<C-w>+', 'Resize up')
map('n', '<M-d>', '<C-w>-', 'Resize down')
