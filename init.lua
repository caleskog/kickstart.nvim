-- File: init.lua
-- Author: caleskog (adapted from https://github.com/nvim-lua/kickstart.nvim)

--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = true

-- Global for plugin configuration utilities
_G.Core = require('core')

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Register new event, `LazyFile` ]]
Core.new_event('LazyFile', { 'BufReadPost', 'BufNewFile', 'BufWritePre' })

require('lazy').setup({
    { import = 'plugins' },
}, {
    change_detection = {
        notify = false,
    },
    ui = {
        -- If you are using a Nerd Font: set icons to an empty table which will use the default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
        icons = Core.config.icons(),
    },
    rocks = {
        hererocks = false, -- assuming global installation of Lua 5.1 on system
    },
})
