-- File: plugins/dap.lua
-- Author: caleskog
-- Description: Some debugging configuration.

local function map(mode, key, invoke, desc)
    desc = desc or ''
    vim.keymap.set(mode, key, invoke, { desc = desc })
end

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

            require('dapui').setup()
            require('nvim-dap-virtual-text').setup({})

            map('n', '<leader>dc', dap.continue, 'Continue')
            map('n', '<leader>dt', dap.run_to_cursor, 'Run to Cursor')

            -- Eval var under cursor
            map('n', '<leader>d?', function()
                ---@diagnostic disable-next-line: missing-fields
                require('dapui').eval(nil, { enter = true })
            end, 'Debugger Eval Under Cursor')

            map('n', '<F5>', dap.continue, 'Debug: Continue')
            map('n', '<F11>', dap.step_into, 'Debug: Step Into')
            map('n', '<F10>', dap.step_over, 'Debug: Step Over')
            map('n', '<F12>', dap.step_out, 'Debug: Step Out')
            map('n', '<F9>', dap.step_back, 'Debug: Step Back')
            map('n', '<F6>', dap.restart, 'Debug: Restart')

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
