---@author caleskog (christoffer.aleskog@gmail.com)
---@file lua/telescope-config.lua
---@description Custom actions for 'Telescope'

local actions = require('telescope.actions')
local transform_mod = require('telescope.actions.mt').transform_mod

local M = {}

--- Open file with system default. create/re-create the corresponding html file.
--- See the following link for more information on how this was made:
--- <https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/actions/set.lua#L127>
---
---@param sources? table<string> A talbe specifying the filetypes that it tryes to convert to `target` before opening the file. Default: {"markdown"}. For possible filetypes see: https://github.com/nvim-lua/plenary.nvim/blob/master/data/plenary/filetypes/base.lua
---@param target? string The filetype that it tries to convert into. Default: ".html"
M.system_default_html = function(sources, target)
    ---@param prompt_bufnr number The prompt bufnr
    return function(prompt_bufnr)
        sources = sources or { 'markdown' }
        target = target or '.html'
        local action_state = require('telescope.actions.state')
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if not entry then
            vim.notify('Nothing currently selected', vim.log.levels.WARN)
            return
        end
        if entry.path or entry.filename then
            local filename = entry.path or entry.filename
            -- vim.notify(filename or 'Nil', vim.log.levels.INFO)
            local file = Core.utils.file
            file.open(vim.fn.fnameescape(filename), sources, target)
        end
        --[[ -- Use default open command
        local action_set = require('telescope.actions.set')
        return action_set.select(prompt_bufnr, 'default') ]]
    end
end

--- Transform custom_actions module and sets the correct metatables.
--- These custom actions includes the following functions: `:replace(f)`, `:replace_if(f, c)`,
--- `replace_map(tbl)` and `enhance(tbl)`. More information on these functions
--- can be found in the `developers.md` and `lua/tests/automated/action_spec.lua`
M = transform_mod(M)
return M
