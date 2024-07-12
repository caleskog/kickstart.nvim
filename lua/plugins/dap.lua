-- File: plugins/dap.lua
-- Author: caleskog
-- Description: Some debugging configuration.

return {
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            'rcarriga/nvim-dap-ui',
            'theHamsta/nvim-dap-virtual-text',
            'nvim-neotest/nvim-nio',
            'williamboman/mason.nvim',
        },
        config = function()
            local dap = require('dap')
            local ui = require('dapui')
            local util = require('../util')

            require('dapui').setup()
            require('nvim-dap-virtual-text').setup({})

            util.map('n', '<leader>dc', dap.continue, 'Continue')
            util.map('n', '<leader>dt', dap.run_to_cursor, 'Run to Cursor')
            util.map('n', '<leader>dd', dap.toggle_breakpoint, 'Debug: Toggle Breakpoint')
            util.map('n', '<leader>dD', function()
                dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
            end, 'Debug: Set Breakpoint with Conditions')

            -- Eval var under cursor
            util.map('n', '<leader>d?', function()
                ---@diagnostic disable-next-line: missing-fields
                require('dapui').eval(nil, { enter = true })
            end, 'Debugger Eval Under Cursor')

            util.map('n', '<F5>', dap.continue, 'Debug: Continue')
            util.map('n', '<F11>', dap.step_into, 'Debug: Step Into')
            util.map('n', '<F10>', dap.step_over, 'Debug: Step Over')
            util.map('n', '<F12>', dap.step_out, 'Debug: Step Out')
            util.map('n', '<F9>', dap.step_back, 'Debug: Step Back')
            util.map('n', '<F6>', dap.restart, 'Debug: Restart')

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
