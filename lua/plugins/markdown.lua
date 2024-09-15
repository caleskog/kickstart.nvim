-- File: plugins/obsidian.lua
-- Author: caleskog

-- Commented out for testing the `markdown-oxide`, link: https://github.com/Feel-ix-343/markdown-oxide
return {
    {
        'MeanderingProgrammer/markdown.nvim',
        main = 'render-markdown',
        opts = {},
        name = 'render-markdown', -- Only needed if you have another plugin named markdown.nvim
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'kyazdani42/nvim-web-devicons',
        },
    },
    {
        'iamcco/markdown-preview.nvim',
        cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
        ft = { 'markdown' },
        build = function()
            vim.fn['mkdp#util#install']()
        end,
        keys = {
            {
                '<leader>pmt',
                '<Plug>MarkdownPreviewToggle',
                desc = 'Toggle Markdown Preview',
            },
            {
                '<leader>pmm',
                '<Plug>MarkdownPreview',
                desc = 'Start Markdown Preview',
            },
            {
                '<leader>pms',
                '<Plug>MarkdownPreviewStop',
                desc = 'Stop Markdown Preview',
            },
        },
    },
    --[[ {
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
