-- File: plugins/image.lua
-- Author: caleskog
-- Description: Everything todo with images.

return {
    {
        '3rd/image.nvim',
        ft = { 'markdown' },
        ---@module 'image'
        ---@type Options
        opts = {
            -- TODO: Don't seems to be working. Might need to change backend!
            backend = 'kitty',
            integrations = {
                markdown = {
                    enabled = true,
                    clear_in_insert_mode = false,
                    download_remote_images = true,
                    only_render_image_at_cursor = true,
                    filetypes = { 'markdown', 'vimwiki' }, -- markdown extensions (ie. quarto) can go here
                },
            },
            max_width = nil,
            max_height = nil,
            max_width_window_percentage = nil,
            max_height_window_percentage = 50,
            kitty_method = 'normal',
        },
    },
}
