-- Other tools (not pre-configured) that Mason will install
local tools = {
    -- 'asmfmt', -- Disabled due to GO assembly specific
    -- 'lua_ls', -- Already specified in 'servers_to_install'
    'stylua',
    'clang-format',
    'cmakelang', -- cmake-formatter
    'codelldb', -- C/C++ debugger
    'gofumpt', -- Go code formatter
    'goimports-reviser', -- Go code formatter
    'golangci-lint', -- Go linter
}

return tools
