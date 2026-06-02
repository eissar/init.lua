vim.filetype.add({
    pattern = {
        ['.*'] = {
            function(path, bufnr)
                local first = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ''
                if first:match('/usr/bin/env.*deno') then
                    return 'typescript'
                end
            end,
        },
    },
})
