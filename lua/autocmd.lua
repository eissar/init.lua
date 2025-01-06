-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- create autocmd for terminal so we can set config with ftplugin
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "term://*",
  command = "set filetype=term",
  group = vim.api.nvim_create_augroup("TermBuffers", { clear = true }),
})
