-- File: plugins/obsidian.lua
-- Author: caleskog

-- Commented out for testing the `markdown-oxide`, link: https://github.com/Feel-ix-343/markdown-oxide
return {
    {
        'jbyuki/nabla.nvim', -- Render LaTeX equations in any filetype
        event = 'VeryLazy',
        keys = {
            {
                '<leader>kv',
                function()
                    require('nabla').toggle_virt({ autogen = true })
                end,
                ft = { 'markdown' },
                desc = 'Enable virtual text',
            },
            {
                '<leader>m',
                function()
                    require('nabla').popup()
                end,
                ft = { 'markdown' },
                desc = 'Popup LaTeX equations',
            },
        },
    },
    {
        -- Video: https://www.youtube.com/watch?v=DgKI4hZ4EEI
        'MeanderingProgrammer/render-markdown.nvim',
        ft = 'markdown',
        event = 'VeryLazy',
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'kyazdani42/nvim-web-devicons',
        },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            latex = { enabled = false },
            win_options = { conceallevel = { rendered = 2 } },
            ---Disabled due to parsing of LaTeX math environments when they don't exist in document.
            ---Exaample: usage of `$HOME/ [...] $HOME` will be parsed as LaTeX math. Thereby messing up the rendering.
            -- on = {
            --     attach = function()
            --         require('nabla').enable_virt({ autogen = true })
            --     end,
            -- },
        },
    },
    {
        'iamcco/markdown-preview.nvim',
        cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
        event = 'VeryLazy',
        build = function()
            vim.fn['mkdp#util#install']()
        end,
        keys = {
            {
                '<leader>kt',
                '<Plug>MarkdownPreviewToggle',
                ft = { 'markdown' },
                desc = 'Toggle Markdown Preview',
            },
            {
                '<leader>km',
                '<Plug>MarkdownPreview',
                ft = { 'markdown' },
                desc = 'Start Markdown Preview',
            },
            {
                '<leader>ks',
                '<Plug>MarkdownPreviewStop',
                ft = { 'markdown' },
                desc = 'Stop Markdown Preview',
            },
        },
    },
    --[[ { -- Video: https://www.youtube.com/watch?v=5ht8NYkU9wQ
        'epwalsh/obsidian.nvim',
        version = '*',
        lazy = true,
        ft = 'markdown',
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        config = function()
            require('obsidian').setup({
                workspaces = {
                    {
                        name = 'Private',
                        path = '~/Obsidian/Notes/Private Notes',
                    },
                    {
                        name = 'Work',
                        path = '~/Obsidian/Notes/Doktorand',
                    },
                    {
                        name = 'Tools',
                        path = '~/Obsidian/Notes/Tools',
                    },
                    {
                        name = 'AI',
                        path = '~/Obsidian/Notes/AI',
                    },
                },
                completion = {
                    nvim_cmp = true,
                    min_chars = 2,
                },
                new_notes_location = 'notes_subdir',
                note_id_func = function(title)
                    return title
                end,
                note_frontmatter_func = function(note)
                    local out = { id = note.id, aliases = note.aliases, tags = note.tags }

                    if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
                        for k, v in pairs(note.metadata) do
                            out[k] = v
                        end
                    end

                    return out
                end,
                mappings = {},

                templates = {
                    subdir = 'Templates',
                    date_format = '%d-%m-%Y',
                    time_format = '%H:%M',
                    tags = '',
                    substitutions = {
                        yesterday = function()
                            return os.date('%d-%m-%Y', os.time() - 86400)
                        end,
                        tomorrow = function()
                            return os.date('%d-%m-%Y', os.time() + 86400)
                        end,
                    },
                },

                ui = {
                    enable = true,
                },
            })
        end,
    }, ]]
}
