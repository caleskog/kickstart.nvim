-- Fike: plugins/init.lua
-- Author: caleskog
-- Description: Miscellaneous plugins that doen't require much configuration.

return {
    -- Use `opts = {}` to force a plugin to be loaded.
    --
    --  This is equivalent to:
    --    require('Comment').setup({})

    { -- "gc" to comment visual regions/lines
        'numToStr/Comment.nvim',
        opts = {},
    },

    -- Here is a more advanced example where we pass configuration
    -- options to `gitsigns.nvim`. This is equivalent to the following Lua:
    --    require('gitsigns').setup({ ... })
    --
    -- See `:help gitsigns` to understand what the configuration keys do
    { -- Adds git related signs to the gutter, as well as utilities for managing changes
        'lewis6991/gitsigns.nvim',
        opts = {
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
            },
        },
    },

    -- {
    --     'EdenEast/nightfox.nvim',
    --     priority = 1000,
    --     init = function()
    --         vim.cmd.colorscheme('nightfox')
    --     end,
    --     opt = true,
    -- },
    {
        -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
        'folke/tokyonight.nvim',
        priority = 1000, -- Make sure to load this before all the other start plugins.
        init = function()
            vim.cmd.colorscheme('tokyonight-night')

            -- You can configure highlights by doing something like:
            -- vim.cmd.hi('Comment gui=none')
        end,
    },

    -- Highlight todo, notes, etc in comments
    {
        -- NOTE: adding a note
        -- TODO: What else?
        -- INPORTANT: This is really important
        -- FIX: this needs fixing
        -- WARNING: be careful, it might break
        -- HACK: hmm, this looks a bit funky
        -- PERF: fully optimised
        -- HELP: Some kind of helpfull message

        'folke/todo-comments.nvim',
        event = 'VimEnter',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope.nvim',
        },
        opts = {
            signs = false,
            keywords = {
                INPORTANT = {
                    icon = '',
                    color = '#ff0000',
                    alt = { 'IMPORTANT', 'CRIT', 'CRITICAL' },
                },
                FIX = {
                    icon = '',
                    color = '#b2182b',
                    alt = { 'FIXME', 'BUG', 'FIX' },
                },
                WARN = {
                    icon = '',
                    color = '#fee08b',
                    alt = { 'WARNING', 'CAUTION' },
                },
                HACK = {
                    icon = '󰶯',
                    color = '#ef8a62',
                },
                PERFORMACE = {
                    icon = '󰅒',
                    color = '#af8dc3',
                    alt = { 'PERF', 'PERFORMANCE', 'OPTIM' },
                },
                TODO = {
                    icon = '',
                    color = '#2166ac',
                    alt = { 'TODO' },
                },
                NOTE = {
                    icon = '',
                    color = '#458588',
                    alt = { 'NOTE', 'INFO' },
                },
                HELP = {
                    icon = '󰞋',
                    color = '#1b7837',
                    alt = { 'HELP' },
                },
            },
            merge_keywords = true,
        },
        keys = {
            { '<leader>ft', '<cmd>TodoTelescope<cr>', desc = 'TodotList' }, -- Using Telescope
        },
    },

    {
        'mbbill/undotree',
        dependencies = {
            'rcarriga/nvim-notify',
        },
        config = function()
            local util = require('../util')
            util.cmap('n', '<leader>fu', 'Telescope undo', 'UndoList')
        end,
    },

    {
        'rcarriga/nvim-notify',
        opts = {},
        config = function()
            local notify = require('notify')
            vim.notify = notify

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
            ---Parsing the custom options for the prin function
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
                -- Check correct nukber of options
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
                    title = 'Print',
                })
            end

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
                    title = 'Print',
                })
            end
            --- Alias for gpdbg function
            _G.gpdebug = _G.gpdbg

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
                    title = 'Print [Warning]',
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
                    title = 'Print [Error]',
                })
            end

            ---@diagnostic disable-next-line: missing-fields
            notify.setup({
                stages = 'fade',
            })
        end,
    },
}
