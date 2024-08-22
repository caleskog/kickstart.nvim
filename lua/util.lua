-- File: util.lua
-- Author: caleskog
-- Description: Utility functions.

local M = {}

local notify = require('notify')

---Available modes for the map functions
---Example:
---     M.Mode['nv'] results in { 'n', 'v' }
---     M.Mode['iv'] results in { 'i', 'v' }
---     M.Mode['ntV'] results in { 'n', 't', 'V' }
---Note:
---     'W' => 'ctrl-v'
---     'Z' => 'ctrl-s'
---
---@class Modes
M.Mode = setmetatable({
    -- See :h mode()
    _modes = { 'n', 'i', 'v', 'V', 'W', 's', 'S', 'Z', 'R', 't' },
}, {
    ---Index function
    ---@param self table
    ---@param key string
    __index = function(self, key)
        local exists = 0
        for i = 1, #key do
            for _, mode in ipairs(self._modes) do
                if key:sub(i, i) == mode then
                    exists = exists + 1
                end
            end
        end
        if exists == string.len(key) then
            local ret_tbl = {}
            for c in key:gmatch('.') do
                table.insert(ret_tbl, c)
            end
            return ret_tbl
        end
        return false
    end,
    __newindex = nil,
})
M.NORMAL = { 'n' }
M.INSERT = { 'i' }
M.VISUAL = { 'v' }
M.TERMINAL = { 't' }

---Map a key to a action.
---@param mode string
---@param key string
---@param invoke any
---@param desc? string
---@param opts? vim.keymap.set.Opts
function M.map(mode, key, invoke, desc, opts)
    desc = desc or ''
    opts = opts or {}
    if not M.Mode[mode] then
        ---@diagnostic disable-next-line: missing-fields
        notify.notify("Invalid mode: '" .. mode .. "'", 'warning', {
            title = 'Utility Library',
        })
        return false
    end
    opts.desc = desc
    vim.keymap.set(M.Mode[mode], key, invoke, opts)
    return true
end

---Map a key to a action, assuming the `invoke` variable holds an expression
---Essentially a wrapper of `util.map(...)`
---@param mode string
---@param key string
---@param invoke string
---@param desc? string
function M.emap(mode, key, invoke, desc)
    return M.map(mode, key, invoke, desc, { expr = true })
end

---Map a key to a action, assuming the `invoke` variable holds a command
---Essentially a wrapper of `util.map(...)`
---@param mode string
---@param key string
---@param invoke string
---@param desc? string
function M.cmap(mode, key, invoke, desc)
    return M.map(mode, key, '<CMD>' .. invoke .. '<CR>', desc)
end

---Map a key to a action, assuming the `invoke` variable holds a function
---Essentially a wrapper of `util.map(...)`
---@param mode string
---@param key string
---@param invoke function
---@param desc? string
---@param opts? vim.keymap.set.Opts
function M.fmap(mode, key, invoke, desc, opts)
    return M.map(mode, key, invoke, desc, opts)
end

---Check if a module exists before requiring it
---@param name string Module name
function M.module_mxists(name)
    local status, _ = pcall(require, name)
    return status
end

---Generate a which-key register table for additional around/inside functionality.
---
---The following is an example of what it would produce:
---     M.WhichKey_ai("[A]rgument")
--- would produce the following which-key register table:
---     {
---         ["aA"] = "[a]round [A]rgument",
---         ["iA"] = "[i]nside [A]rgument",
---     }
---
---Note: The function `M.flatten` is needed if the function will be used more than once.
---
---@param mode string
---@param identifier string Identifier name including the textobject id surrounded by [].
---@return table
function M.WhichKey_ai(mode, identifier)
    local i, j = string.find(identifier, '%[.%]')
    if i == nil then
        return {}
    end
    local key = string.sub(identifier, i + 1, j - 1)
    return {
        { 'a' .. key, desc = '[a]round ' .. identifier, mode = mode },
        { 'i' .. key, desc = '[i]inside ' .. identifier, mode = mode },
    }
end

---Dump the content of a dictionary into a new file.
---
---@param dict table Dictionary to be written to file.
---@param filename? string Name of the dump file. Deafult: `'dict.dump'`
function M.dump_dict(dict, filename)
    filename = filename or 'dict.dump'
    local content = vim.inspect(dict)
    local file = io.open(filename, 'w')
    if not file then
        error('Could not open file ' .. filename .. 'for writing')
    end
    file:write(content)
    file:close()
end

---Flatten a dictionary of keys of type string (`[<string>]`).
---
---@param tlb table The table to be flattend
---@param depth? integer The depth to be considered. Default: `-1`
---@return table # The flattened table
function M.flatten(tlb, depth)
    depth = depth or 1

    return vim.iter(tlb):flatten(depth):totable()
end

---Check if a table contains a specific value
---
---@param tbl table
---@param val any
---@return boolean
function M.contains(tbl, val)
    for _, value in ipairs(tbl) do
        if value == val then
            return true
        end
    end
    return false
end

---Convert file to `target` format.
---
---NOTE: This function uses `plenary` for path operations. Please make sure that it is loaded before using this function.
---
---@param filepath string The path to the file that should be converted.
---@param filetypes? table<string> A list of filetypes that should be converted into `target` files. Default: {"markdown"}. For possible filetypes see: https://github.com/nvim-lua/plenary.nvim/blob/master/data/plenary/filetypes/base.lua
---@param targets? string|table<string> The prefered convertion result file type(s). Default: ".html"
---@param overwrite? boolean If it should overwrite the target file if it exists. Default: false
---@param to_all? boolean If it should convert the file to all `targets` or only the first `targets`. Default: false
---@return string|nil|table # The path to the created file, all created files (Only returned if `to_all` is set to true and `overwrite` is set to false), the filepath, or nil. (See EXITCODES for details on exactly when they each are returned).
---@return number # Exit code (See EXITCODES for details).
---
---EXITCODES:
--- 1 => `filepath` does not exists, (returns `nil`)
--- 2 => Trying to overwrite an existing file, (returns `nil`)
--- 3 => Overwrote an existing target, (returns target file)
--- 4 => Created the target file, (returns target file)
--- 5 => File is NOT of a type in `filetypes`, (returns `filepath`)
--- 6 => `filepath` is already of type `target`, (returns `filepath`)
--- 7 => Convert `filepath` to all `targets`
function M.convert(filepath, filetypes, targets, overwrite, to_all)
    local Path = require('plenary.path')
    local filetype = require('plenary.filetype')

    -- Default values
    filetypes = filetypes or { 'markdown' }
    targets = targets or '.html'
    overwrite = overwrite or false
    to_all = to_all or false

    -- Check if the path exists
    if not Path:new(filepath):exists() then
        return nil, 1
    end

    if type(targets) == 'table' then
        for _, t in ipairs(targets) do
            if filepath:match('^.+(%..+)$') == t then
                return filepath, 6
            end
        end
    elseif filepath:match('^.+(%..+)$') == targets then
        return filepath, 6
    end

    local extension = filetype.detect(filepath, {})
    -- Opsions table when converting the file with the bash script
    local options = {}

    -- If filetype is 'markdown' then retrieve the conversion metadata and place it in the options table
    if extension == 'markdown' then
        local mdfile = io.open(filepath, 'r')
        if mdfile then
            local metadata_content = ''
            local line = mdfile:read()
            while line do
                if line:match('^---$') then
                    line = mdfile:read()
                    while line and not line:match('^---$') do
                        metadata_content = metadata_content .. line .. '\n'
                        line = mdfile:read()
                    end
                    break
                end
                line = mdfile:read()
            end
            local yaml = require('tinyyaml')
            local metadata = yaml.parse(metadata_content)
            -- Find the convert table in the metadata
            if metadata and metadata.convert then
                -- append the metadata to the options table
                for k, v in pairs(metadata.convert) do
                    options[k] = v
                end
            end
            -- Close the file
            mdfile:close()
        end
    end

    -- Options that start with a '<key>-' are considered as metatable options for the pandoctool
    -- The <key> need to be an existing key in the metatable
    local pandoc_metatable = {}
    for k, v in pairs(options) do
        if k:match('^.+-.+$') then
            local main_key, sub_key = k:match('^(.+)-(.+)$')
            if options[main_key] then
                pandoc_metatable[sub_key] = v
                options[k] = nil
            end
        end
    end

    -- Convert options table to string
    local options_str = ''
    for k, v in pairs(options) do
        if type(v) == 'boolean' then
            if v then
                options_str = options_str .. ' --' .. k
            end
        else
            options_str = options_str .. ' --' .. k .. ' ' .. v
        end
    end

    -- Convert pandoc metatable to string
    for k, v in pairs(pandoc_metatable) do
        options_str = options_str .. ' --metadata ' .. k .. '=' .. tostring(v)
    end

    -- Check if the file is a supported format for converting
    ---@diagnostic disable-next-line: param-type-mismatch
    if M.contains(filetypes, extension) then
        local targetpath = filepath:match('^(.+/.+)%.(.+)$')
        if to_all and type(targets) == 'table' and not overwrite then
            local target_paths = {}
            for _, t in ipairs(targets) do
                local target = targetpath .. t
                local cmd = '~/.bash.ext/converters/convert.sh ' .. filepath .. ' ' .. target .. ' ' .. options_str .. ' &>/dev/null'
                os.execute(cmd)
                target_paths[#target_paths + 1] = target
            end
            return target_paths, 7
        end

        targetpath = targetpath .. targets

        if not overwrite and Path:new(targetpath):exists() then
            return nil, 2
        end
        -- vim.notify('filepath: ' .. filepath, vim.log.levels.INFO)
        -- vim.notify('targetpath: ' .. targetpath, vim.log.levels.INFO)
        local cmd = '~/.bash.ext/converters/convert.sh ' .. filepath .. ' ' .. targetpath .. ' ' .. options_str .. ' &>/dev/null'
        os.execute(cmd)
        if overwrite and Path:new(targetpath):exists() then
            return targetpath, 3
        end
        return targetpath, 4
    end
    return filepath, 5
end

---Open file with system default app. If possible, create/re-create the corresponding `target` file.
---
---NOTE: This function uses `plenary` for path operations. Please make sure that it is loaded before using this function.
---
---@param filepath? string The path to the file that should be opend. Default: vim.api.nvim_buf_get_name(0).
---@param filetypes? table<string> A list of filetypes that should be converted into `target` files when trying to open them. Default: {"markdown"}. For possible extensions see: https://github.com/nvim-lua/plenary.nvim/blob/master/data/plenary/filetypes/base.lua
---@param target? string The prefered convertion result file type. Default: ".html".
function M.open(filepath, filetypes, target)
    filepath = filepath or vim.api.nvim_buf_get_name(0)
    filetypes = filetypes or { 'markdown' }
    target = target or '.html'
    local targetpath, ecode = M.convert(filepath, filetypes, target, true)
    if ecode == 1 then
        vim.notify('The path [' .. filepath .. '] does not exist', vim.log.levels.INFO)
        return
    elseif ecode == 3 then
        vim.notify('Updateing complementary `' .. target .. '` file', vim.log.levels.INFO)
    elseif ecode == 4 then
        vim.notify('Creating complementary `' .. target .. '` file', vim.log.levels.INFO)
    end
    vim.notify('Opening file', vim.log.levels.INFO)
    vim.api.nvim_exec2('!xdg-open ' .. targetpath, { output = true })
end

return M
