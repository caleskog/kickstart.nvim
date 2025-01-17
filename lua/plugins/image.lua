-- File: plugins/image.lua
-- Author: caleskog
-- Description: Everything todo with images.

return {
    {
        '3rd/image.nvim',
        enabled = false,
        ft = { 'markdown' },
        config = function()
            ---@module 'image'
            ---@type Options
            local opts = {
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
            }
            --- Kitty's graphics protocol can be found here: https://sw.kovidgoyal.net/kitty/graphics-protocol/
            if vim.fn.executable('kitty') == 1 then
                require('image').setup(opts)
            else
                gpwarning("`image.nvim` can't render images on terminal not supporting latest `kitty's graphics protocol`")
            end
        end,
    },
}
