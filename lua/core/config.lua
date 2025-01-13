---@class caleskog.nvim.core.Config
local M = {}

---@class caleskog.nvim.core.config.Config User configuration
---@field notifier "snacks" | "nvim-notify"

---@alias UserConfig caleskog.nvim.core.config.Config

--- Default configuration
---@type UserConfig
M.default = {
    -- The default value for the notifier
    notifier = 'snacks',
}

---User configuration
---@diagnostic disable-next-line: missing-fields
M.config = {}

setmetatable(M, {
    __index = function(_, key)
        if M.config[key] == nil then
            error('Config key ' .. key .. ' not found')
        end
        return M.config[key]
    end,
    __newindex = nil,
})

function M.icons()
    return vim.g.have_nerd_font and {}
        or {
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
        }
end

---Delay notifications till vim.notify was replaced or after 500ms
---Taken from LazyVim: https://github.com/LazyVim/LazyVim/blob/d0c366e4d861b848bdc710696d5311dca2c6d540/lua/lazyvim/util/init.lua#L116
function M.lazy_notify()
    local notifs = {}
    local function temp(...)
        table.insert(notifs, vim.F.pack_len(...))
    end

    local orig = vim.notify
    vim.notify = temp

    local timer = vim.uv.new_timer()
    local check = assert(vim.uv.new_check())

    local replay = function()
        timer:stop()
        check:stop()
        if vim.notify == temp then
            vim.notify = orig -- put back the original notify if needed
        end
        vim.schedule(function()
            ---@diagnostic disable-next-line: no-unknown
            for _, notif in ipairs(notifs) do
                vim.notify(vim.F.unpack_len(notif))
            end
        end)
    end

    -- wait till vim.notify has been replaced
    check:start(function()
        if vim.notify ~= temp then
            replay()
        end
    end)
    -- or if it took more than 500ms, then something went wrong
    timer:start(500, 0, replay)
end

function M.custom_notifications()
    local apply_rule = function(str, apply, rule)
        local lines = vim.split(str, '\n')
        local rules_fn = {
            ['<'] = function(line, _apply)
                -- Remove '_apply' number of characters from the beginning of the line
                if type(_apply) == 'number' then
                    return line:sub(_apply + 1)
                end
                -- Remove '_apply' if if starts with it
                if type(_apply) == 'string' and line:sub(1, #_apply) == _apply then
                    return line:sub(#_apply + 1)
                end
                return line
            end,
            ['>'] = function(line, _apply)
                -- Add '_apply' to the beginning of the line
                return _apply .. line
            end,
        }
        local rules = {}
        for j = 1, #rule do
            local char = rule:sub(j, j)
            table.insert(rules, rules_fn[char])
        end
        -- Calculate how many characters should be removed
        if not apply and rule:find('<') then
            local minimum_chars = math.huge
            for i = 1, #lines do
                -- use regex to find the spaces at the beginning of the line
                local _, spaces = lines[i]:find('^%s*')
                if spaces and spaces < #lines[i] and spaces < minimum_chars and spaces > 0 then
                    minimum_chars = spaces
                end
            end
            apply = minimum_chars
        end
        -- Apply the 'rules' to each line
        for i = 1, #lines do
            for j = 1, #rules do
                lines[i] = rules[j](lines[i], apply)
            end
        end
        return table.concat(lines, '\n')
    end
    ---Parsing the custom options for the print function
    ---@param params table A list of parameters to be printed
    ---@param options table Options for the print function
    local parse_param_options = function(params, options)
        options = options or nil
        -- If there are no options, return the params
        if not options or not type(options) == 'table' then
            return params
        end
        -- Check if the option is the custom option
        if type(options[1]) == 'string' and tonumber(options[1]) then
            options[1] = tonumber(options[1])
        else -- If not a number, return the params
            return params
        end
        -- Check correct number of options
        if #options == 1 then
            return params
        end
        -- Parse the 'code'
        -- Each digit will be one element in the list
        local code = options[1]
        local order = {}
        while code > 0 do
            table.insert(order, code % 10)
            code = math.floor(code / 10)
        end
        -- Parse the custom options
        for i = 2, #options do
            local param_index = order[i - 1]
            local value = options[i]
            if type(value) == 'table' and type(params[param_index]) == 'string' then
                local apply = value.apply or nil
                local rule = value.rule or nil
                if type(apply) == 'function' then
                    params[param_index] = apply(params[param_index])
                elseif rule then
                    params[param_index] = apply_rule(params[param_index], apply, rule)
                end
            end
        end
        return params
    end

    -- Helper function for printing messages to the screen
    local define_args = function(inspect, options, args)
        inspect = inspect or false
        local params = {}
        for i = 1, #args do
            if inspect or type(args[i]) == 'table' then
                table.insert(params, vim.inspect(args[i]))
            else
                table.insert(params, args[i])
            end
        end
        return parse_param_options(params, options)
    end
    ---Override the default print function to make use of notify
    _G.gprint = function(...)
        local pre_args = { ... }
        -- If the last argument is a table containing the key 'param_opts' extract it
        local options = {}
        if type(select(-1, ...)) == 'table' and select(-1, ...).param_opts then
            options = table.remove(pre_args, #pre_args).param_opts
        end
        -- Define the arguments
        local args = define_args(false, options, pre_args)
        vim.notify(table.concat(args, ' '), 'info', {
            title = 'Info',
        })
    end
    --- Alias for gprint function
    ---@type fun(...)
    _G.gp = _G.gprint

    --- Add global function for printing DEBUG messages
    _G.gpdbg = function(...)
        local pre_args = { ... }
        -- If the last argument is a table containing the key 'param_opts' extract it
        local options = {}
        if type(select(-1, ...)) == 'table' and select(-1, ...).param_opts then
            options = table.remove(pre_args, #pre_args).param_opts
        end
        -- Define the arguments
        local args = define_args(true, options, pre_args)
        vim.notify(table.concat(args, ' '), 'debug', {
            title = 'Debug',
        })
    end
    --- Alias for gpdbg function
    _G.gpdebug = _G.gpdbg
    _G.gpd = _G.gpdbg

    --- Add global function for printing WARNING messages
    _G.gpwarning = function(...)
        local pre_args = { ... }
        -- If the last argument is a table containing the key 'param_opts' extract it
        local options = {}
        if type(select(-1, ...)) == 'table' and select(-1, ...).param_opts then
            options = table.remove(pre_args, #pre_args).param_opts
        end
        -- Define the arguments
        local args = define_args(false, options, pre_args)
        vim.notify(table.concat(args, ' '), 'warning', {
            title = 'Warning',
        })
    end

    --- Add global function for printing ERROR messages
    --- This function will not exit the program, just continue running.
    _G.gperror = function(...)
        local pre_args = { ... }
        -- If the last argument is a table containing the key 'param_opts' extract it
        local options = {}
        if type(select(-1, ...)) == 'table' and select(-1, ...).param_opts then
            options = table.remove(pre_args, #pre_args).param_opts
        end
        -- Define the arguments
        local args = define_args(false, options, pre_args)
        vim.notify(table.concat(args, ' '), 'error', {
            title = 'Error',
        })
    end
end

M.did_init = false
---Initialize the configuration
---@param config? caleskog.nvim.core.config.Config
function M.init(config)
    if M.did_init then
        return
    end
    M.did_init = true
    M.lazy_notify()
    M.custom_notifications()

    -- Set the configurations
    ---@type caleskog.nvim.core.config.Config
    config = config or {}
    M.config = vim.tbl_deep_extend('force', M.default, config)
end

function M.is(key, value)
    return M.config[key] == value
end

return M
