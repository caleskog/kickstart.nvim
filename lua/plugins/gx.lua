-- File: plugins/gx.lua
-- Author: caleskog
-- Description: Adding more capabilities to the `gx` keymapping.

return {
    {
        'chrishrb/gx.nvim',
        keys = { { 'gx', '<cmd>Browse<cr>', mode = { 'n', 'x' }, desc = 'Open URIs, Github Repos, etc.' } },
        cmd = { 'Browse' },
        init = function()
            vim.g.netrw_nogx = 1 -- disable netrw gx
        end,
        dependencies = { 'nvim-lua/plenary.nvim' },
        submodules = false, -- not needed, submodules are required only for tests
        config = function()
            ---@diagnostic disable-next-line: missing-fields
            require('gx').setup({
                open_browser_args = { '--background' },
                handlers = {
                    plugin = true, -- open plugin links in lua (e.g. packer, lazy, ..)
                    github = true, -- open github issues
                    package_json = true, -- open dependencies from package.json
                    search = true, -- search the web/selection on the web if nothing else is found
                    rust = { -- custom handler to open rust's cargo packages
                        name = 'rust',
                        filename = 'Cargo.toml',
                        handle = function(mode, line, _)
                            local crate = require('gx.helper').find(line, mode, '(%w+)%s-=%s')

                            if crate then
                                return 'https://crates.io/crates/' .. crate
                            end
                        end,
                    },
                },
                handler_options = {
                    search_engine = 'google', -- you can select between google, bing, duckduckgo, and ecosia
                    select_for_search = false, -- if your cursor is e.g. on a link, the pattern for the link AND for the word will always match. This disables this behaviour for default so that the link is opened without the select option for the word AND link
                    git_remotes = { 'upstream', 'origin' }, -- list of git remotes to search for git issue linking, in priority
                    git_remote_push = false, -- use the push url for git issue linking,
                },
            })
        end,
    },
}
