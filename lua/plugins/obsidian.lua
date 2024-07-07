-- File: plugins/obsidian.lua
-- Author: caleskog

return {
    {
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
    },
}
