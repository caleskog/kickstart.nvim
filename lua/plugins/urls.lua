-- File: plugins/gx.lua
-- Author: caleskog
-- Description: Adding more capabilities to the `gx` keymapping.

-- TODO: Test if it can open .md, .pdf, and .html files. Open them with util.open.

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
            -- ~/.config/nvim/Neovim.html
            ---@diagnostic disable-next-line: missing-fields
            require('gx').setup({
                -- open_browser_args = { '--background' },
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
                    -- ~/.config/nvim/Neovim.html
                    html = { -- Custom handler to open local files via browser (possible convert to html)
                        name = 'html',
                        handle = function(mode, line, _)
                            local helper = require('gx.helper')
                            local Path = require('plenary.path')
                            local util = require('../util')

                            -- Need to be in normal mode
                            if mode ~= 'n' then
                                return
                            end

                            local pattern = '([0-9a-zA-Z%-%._/~&{}]+)'
                            ---@type string|nil
                            local filename = helper.find(line, mode, pattern)
                            if filename then
                                ---@type string
                                local filepath = Path:new(filename):expand()

                                -- Convert filepath to HTML file if possible
                                local targetpath, ecode = util.convert(filepath, { 'markdown' }, { '.html', '.pdf' }, false, false)
                                -- vim.notify(tostring(ecode), vim.log.levels.INFO)

                                -- If not a local file, then return
                                if ecode == 1 then
                                    return
                                end
                                -- Not allowed to overwrite the target file
                                if ecode == 2 then
                                    return
                                end

                                -- Do not open if filepath is not of a supported file format
                                if ecode == 5 then
                                    return
                                end

                                -- print('URI: [' .. vim.uri_from_fname(filepath) .. ']')
                                ---@diagnostic disable-next-line: param-type-mismatch
                                return vim.uri_from_fname(targetpath)
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
