---@meta

---@class caleskog.nvim.ConfigGlobals
vim.g = vim.g or {}

_G.Core = require('core')

--- @class caleskog.nvim.autocmd.callback_event
--- @field id number autocommand id
--- @field event string name of the triggered event `autocmd-events`
--- @field group number|nil autocommand group id, if any
--- @field match string expanded value of <amatch>
--- @field buf number expanded value of <abuf>
--- @field file string expanded value of <afile>
--- @field data any arbitrary data passed from `nvim_exec_autocmds()`
