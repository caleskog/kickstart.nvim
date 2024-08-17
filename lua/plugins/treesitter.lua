-- File: plugins/treesitter.lua
-- Author: caleskog
-- Description: Everything todo with `nvim-treesitter`, i.e., highlight, edit, and navigate code.

---@return LazySpec
return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        opts = {
            ensure_installed = {
                'bash',
                'c',
                'cpp',
                'cmake',
                'html',
                'lua',
                'markdown',
                'markdown_inline',
                -- 'regex',
                'vim',
                -- 'vimdoc',
                'tmux',
                'json',
                'gitignore',
                'query',
            },
            -- Autoinstall languages that are not installed
            auto_install = true,
            highlight = {
                enable = true,
                -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
                --  If you are experiencing weird indenting issues, add the language to
                --  the list of additional_vim_regex_highlighting and disabled languages for indent.
                -- additional_vim_regex_highlighting = { 'ruby' },
            },
            indent = {
                enable = true --[[ , disable = { 'ruby' } ]],
            },
        },
        config = function(_, opts)
            -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

            ---@diagnostic disable-next-line: missing-fields
            require('nvim-treesitter.configs').setup(opts)

            -- There are additional nvim-treesitter modules that you can use to interact
            -- with nvim-treesitter. You should go explore a few and see what interests you:
            --
            --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
            --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
            --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
        end,
    },
}
