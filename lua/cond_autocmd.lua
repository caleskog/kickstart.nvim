local M = {}

--- @class caleskog.nvim.autocmd.callback_event
--- @field id number autocommand id
--- @field event string name of the triggered event `autocmd-events`
--- @field group number|nil autocommand group id, if any
--- @field match string expanded value of <amatch>
--- @field buf number expanded value of <abuf>
--- @field file string expanded value of <afile>
--- @field data any arbitrary data passed from `nvim_exec_autocmds()`

---Create an autocmd group that handles LSP highlights in the current buffer, and clears them when the LSP detaches.
---The autocmd group is only created if the LSP client supports the `textDocument/documentHighlight` method.
---@param client vim.lsp.Client|nil
---@param event caleskog.nvim.autocmd.callback_event
---@param highlight_group_name any
---@param detach_group_name any
---@return boolean # If the LSP client supports the `textDocument/documentHighlight` method.
function M.lsp_highlight(client, event, highlight_group_name, detach_group_name)
    highlight_group_name = highlight_group_name or 'caleskog-lsp-highlight'
    detach_group_name = detach_group_name or 'caleskog-lsp-detach'
    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
        local highlight_group = vim.api.nvim_create_augroup(highlight_group_name, { clear = false })

        -- See `:help CursorHold` for information about when this is executed
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_group,
            callback = function(_)
                -- treesitter available -> don't highlight strings
                local ok, ts = pcall(require, 'nvim-treesitter.ts.utils')
                if ok then
                    -- Use treesitter to check if cursor is on a string
                    local winnr = vim.api.nvim_get_current_win()
                    local node = ts.get_node_at_cursor(winnr)
                    -- If cursor is on a string, don't highlight references
                    local string_node_types = { 'string', 'string_literal', 'string_content' }
                    if node and vim.tbl_contains(string_node_types, node:type()) then
                        return
                    end
                end
                vim.lsp.buf.document_highlight()
            end,
        })
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_group,
            callback = vim.lsp.buf.clear_references,
        })

        -- When the LSP detaches, clear the references and clear the autocmds
        vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup(detach_group_name, { clear = true }),
            callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = 'caleskog-lsp-highlight', buffer = event2.buf })
            end,
        })
        return true
    else
        return false
    end
end

return M
