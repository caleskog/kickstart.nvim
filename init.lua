-- File: init.lua
-- Author: caleskog (adapted from https://github.com/nvim-lua/kickstart.nvim)
--  HELP: The following references can be usefull:
--  - https://learnxinyminutes.com/docs/lua/
--  - :help lua-guide (or HTML version: https://neovim.io/doc/user/lua-guide.html)
--  - :Tutor

--  HELP: `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = true

-- [[Settings]]
-- require('plugin.options')

-- [[Keybindings]]
-- require('plugin.keymaps')

-- [[Autocommands]]
-- require('autocommands')

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

local function add_lazy_file()
    -- Add support for the LazyFile event
    local Event = require('lazy.core.handler.event')
    Event.mappings.LazyFile = { id = 'LazyFile', event = { 'BufReadPost', 'BufNewFile', 'BufWritePre' } }
    Event.mappings['User LazyFile'] = Event.mappings.LazyFile
end

add_lazy_file()

require('lazy').setup({
    { import = 'plugins' },
    -- require 'kickstart.plugins.debug',
    -- require 'kickstart.plugins.indent_line',
    -- require 'kickstart.plugins.lint',
}, {
    change_detection = {
        notify = false,
    },
    ui = {
        -- If you are using a Nerd Font: set icons to an empty table which will use the default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
        icons = vim.g.have_nerd_font and {} or {
            cmd = '⌘',
            config = '🛠',
            event = '📅',
            ft = '📂',
            init = '⚙',
            keys = '🗝',
            plugin = '🔌',
            runtime = '💻',
            require = '🌙',
            source = '📄',
            start = '🚀',
            task = '📌',
            lazy = '💤 ',
        },
    },
    rocks = {
        hererocks = false, -- assuming global installation of Lua 5.1 on system
    },
})
