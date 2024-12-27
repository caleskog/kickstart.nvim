return vim.tbl_map(function(path)
    return { import = path }
end, Core.spec_files('coding'))
