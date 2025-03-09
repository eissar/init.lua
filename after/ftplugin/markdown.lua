require 'plugins.markdown-functions'
-- vim.api.nvim_set_keymap('v', '<C-k>', ':lua MarkdownLink()<cr>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<C-k>', ':lua InsertMarkdownLink()<cr>', { noremap = true, silent = true })

-- vim.api.nvim_set_keymap('n', '<leader>prm', ':lua openMarkdownInBrowser()<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>prm', ':lua OpenMarkdownInBrowser()<cr>', { noremap = true, silent = true })

--
-- vim.keymap.set("n", "<leader>gt", ":lua moveCursorToTagsMarkdown()<cr>", { noremap = true, buffer = true})
-- vim.keymap.set("n", "<leader>ih",":lua insertHeadingsFromMarkdownFile()<cr>", { noremap = true, buffer = true })
-- vim.keymap.set("n", "<leader>[", ":lua insertWikiLink()<cr>", { noremap = true, buffer = true })
-- vim.keymap.set("n", "<leader>]", ":lua insertWikiLinkWithCurrentWorkingDirectoryPath()<cr>", { noremap = true, buffer = true })

-- removes trailing whitespace on save
vim.api.nvim_create_autocmd('BufWritePre', {
    callback = function()
        local save_cursor = vim.fn.getpos '.'
        vim.cmd [[%s/\s\+$//e]]
        vim.fn.setpos('.', save_cursor)
    end,
})
