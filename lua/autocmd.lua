-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text; See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- create autocmd for terminal so we can set config with ftplugin
vim.api.nvim_create_autocmd('BufWinEnter', {
    pattern = 'term://*',
    command = 'set filetype=term',
    group = vim.api.nvim_create_augroup('TermBuffers', { clear = true }),
})

-- removes trailing whitespace on save
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*.md',
    callback = function()
        local save_cursor = vim.fn.getpos '.'
        vim.cmd [[%s/\s\+$//e]]
        vim.fn.setpos('.', save_cursor)
    end,
})

-- Automatically update winbar when the cwd changes
vim.api.nvim_create_autocmd({ 'DirChanged', 'BufWinEnter', 'CmdlineLeave' }, {
    callback = function()
        vim.opt.winbar = vim.fn.getcwd()
    end,
})

-- Auto resize splits when the terminal's window is resized
vim.api.nvim_create_autocmd('VimResized', {
    command = 'wincmd =',
})
