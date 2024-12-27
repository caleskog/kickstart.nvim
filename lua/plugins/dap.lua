-- File: plugins/dap.lua
-- Author: caleskog
-- Description: Some debugging configuration.

---Keymaps for debugging.
local keymaps = {
    ['<leader>dc'] = { 'require("dap").continue()', 'Debug: Continue' },
    ['<leader>dr'] = { 'require("dap").run_to_cursor()', 'Debug: Run to Cursor' },
    ['<leader>dt'] = { 'require("dap").toggle_breakpoint()', 'Debug: Toggle Breakpoint' },
    ['<leader>ds'] = { 'require("dap").step_into()', 'Debug: Step Into' },
    ['<leader>dn'] = { 'require("dap").step_over()', 'Debug: Step Over' },
    ['<leader>do'] = { 'require("dap").step_out()', 'Debug: Step Out' },
    ['<leader>db'] = { 'require("dap").step_back()', 'Debug: Step Back' },
    ['<leader>dT'] = { 'require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))', 'Debug: Set Breakpoint with Conditions' },
    ['<leader>d?'] = { 'require("dapui").eval(nil, { enter = true })', 'Debug: Evaluate Under Cursor' },
}

local function setup_adapters()
    return {
        ['gdb'] = {
            type = 'executable',
            command = 'gdb',
            name = 'gdb',
            args = { '--interpreter=dap', '--eval-command', 'set print pretty on' },
        },
        ['lldb'] = {
            type = 'executable',
            command = '/usr/bin/lldb-vscode', -- Might be something else
            name = 'lldb',
        },
    }
end

local function setup_cpp_configuration()
    return {
        ['cpp'] = {
            {
                name = 'Launch',
                type = 'cpp',
                request = 'launch',
                program = function()
                    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end,
                cwd = '${workspaceFolder}',
                stopAtBeginningOfMainSubprogram = false,
            },
            {
                name = 'Select and attach to process',
                type = 'gdb',
                request = 'attach',
                program = function()
                    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end,
                pid = function()
                    local name = vim.fn.input('Executable name (filter): ')
                    return require('dap.utils').pick_process({ filter = name })
                end,
                cwd = '${workspaceFolder}',
            },
        },
    }
end

return {
    {
        'mfussenegger/nvim-dap',
        event = 'VeryLazy',
        dependencies = {
            'rcarriga/nvim-dap-ui',
            'theHamsta/nvim-dap-virtual-text',
            'nvim-neotest/nvim-nio',
            'williamboman/mason.nvim',
        },
        config = function()
            local dap = require('dap')
            local ui = require('dapui')

            -- Setup DAP UI and virtual text.
            require('dapui').setup()
            require('nvim-dap-virtual-text').setup({})

            -- Setup adapters and configurations.
            dap.adapters = setup_adapters()
            dap.configurations = setup_cpp_configuration()

            -- Keybindings for debugging.
            for key, value in pairs(keymaps) do
                Core.utils.keymap.map('n', key, value[1], value[2])
            end

            dap.listeners.before.attach.dapui_config = function()
                ui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                ui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                ui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                ui.close()
            end
        end,
    },
}
