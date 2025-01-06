---@author caleskog (christoffer.aleskog@gmail.com)
---@file lua/plugins/finders/oldfiles.lua
---@description Modified version of the `telescope.builtin.oldfiles` picker which include option for including the current session buffers even if the files are not in current working directory.

local M = {}

local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local Path = require('plenary.path')
local pickers = require('telescope.pickers')

local conf = require('telescope.config').values

-- Makes sure aliased options are set correctly
local function apply_cwd_only_aliases(opts)
    local has_cwd_only = opts.cwd_only ~= nil
    local has_only_cwd = opts.only_cwd ~= nil

    if has_only_cwd and not has_cwd_only then
        -- Internally, use cwd_only
        opts.cwd_only = opts.only_cwd
        opts.only_cwd = nil
    end

    return opts
end

---@return boolean
local function buf_in_cwd(bufname, cwd)
    if cwd:sub(-1) ~= Path.path.sep then
        cwd = cwd .. Path.path.sep
    end
    local bufname_prefix = bufname:sub(1, #cwd)
    return bufname_prefix == cwd
end

M.oldfiles = function(opts)
    opts = apply_cwd_only_aliases(opts)
    opts.include_current_session = vim.F.if_nil(opts.include_current_session, true)

    local current_buffer = vim.api.nvim_get_current_buf()
    local current_file = vim.api.nvim_buf_get_name(current_buffer)
    local results = {}
    local always_results = {}

    if opts.include_current_session then
        for _, buffer in ipairs(vim.split(vim.fn.execute(':buffers! t'), '\n')) do
            local match = tonumber(string.match(buffer, '%s*(%d+)'))
            local open_by_lsp = string.match(buffer, 'line 0$')
            if match and not open_by_lsp then
                local file = vim.api.nvim_buf_get_name(match)
                if vim.uv.fs_stat(file) and match ~= current_buffer then
                    if opts.always_include_current_session then
                        table.insert(always_results, file)
                    else
                        table.insert(results, file)
                    end
                end
            end
        end
    end

    for _, file in ipairs(vim.v.oldfiles) do
        local file_stat = vim.uv.fs_stat(file)
        if file_stat and file_stat.type == 'file' and not vim.tbl_contains(results, file) and file ~= current_file then
            table.insert(results, file)
        end
    end

    if opts.cwd_only or opts.cwd then
        local cwd = opts.cwd_only and vim.uv.cwd() or opts.cwd
        results = vim.tbl_filter(function(file)
            return buf_in_cwd(file, cwd)
        end, results)
    end

    if opts.always_include_current_session then
        -- Concatenate the always results to the end of the results
        for _, file in ipairs(always_results) do
            -- Disallow duplicates
            if not vim.tbl_contains(results, file) then
                table.insert(results, file)
            end
        end
    end

    pickers
        .new(opts, {
            prompt_title = 'Oldfiles',
            finder = finders.new_table({
                results = results,
                entry_maker = opts.entry_maker or make_entry.gen_from_file(opts),
            }),
            sorter = conf.file_sorter(opts),
            previewer = conf.file_previewer(opts),
        })
        :find()
end

return M
