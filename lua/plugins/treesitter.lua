-- File: plugins/treesitter.lua
-- Author: caleskog
-- Description: Everything todo with `nvim-treesitter`, i.e., highlight, edit, and navigate code.

---@return LazySpec
return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = { 'LazyFile', 'VeryLazy' },
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        opts = {
            ensure_installed = {
                'bash',
                'c',
                'cpp',
                'cmake',
                'diff',
                'html',
                'javascript',
                'jsdoc',
                'json',
                'jsonc',
                'lua',
                'luadoc',
                'luap',
                'markdown',
                'markdown_inline',
                'printf',
                'python',
                'tmux',
                'gitignore',
                'query',
                'regex',
                'toml',
                'tsx',
                'typescript',
                'vim',
                'vimdoc',
                'xml',
                'yaml',
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
            textobjects = { -- Taken from LazyVim: https://github.com/LazyVim/LazyVim/blob/d0c366e4d861b848bdc710696d5311dca2c6d540/lua/lazyvim/plugins/treesitter.lua
                move = {
                    enable = true,
                    goto_next_start = { [']f'] = '@function.outer', [']c'] = '@class.outer', [']a'] = '@parameter.inner' },
                    goto_next_end = { [']F'] = '@function.outer', [']C'] = '@class.outer', [']A'] = '@parameter.inner' },
                    goto_previous_start = { ['[f'] = '@function.outer', ['[c'] = '@class.outer', ['[a'] = '@parameter.inner' },
                    goto_previous_end = { ['[F'] = '@function.outer', ['[C'] = '@class.outer', ['[A'] = '@parameter.inner' },
                },
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
