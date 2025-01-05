require 'markdown-functions'
vim.api.nvim_set_keymap('v', '<C-k>', ':lua MarkdownLink()<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', ':lua InsertMarkdownLink()<cr>', { noremap = true, silent = true })

-- vim.api.nvim_set_keymap('n', '<leader>prm', ':lua openMarkdownInBrowser()<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>prm', ":lua OpenMarkdownInBrowser()<cr>", { noremap = true, silent = true })

--
-- vim.keymap.set("n", "<leader>gt", ":lua moveCursorToTagsMarkdown()<cr>", { noremap = true, buffer = true})
-- vim.keymap.set("n", "<leader>ih",":lua insertHeadingsFromMarkdownFile()<cr>", { noremap = true, buffer = true })
-- vim.keymap.set("n", "<leader>[", ":lua insertWikiLink()<cr>", { noremap = true, buffer = true })
-- vim.keymap.set("n", "<leader>]", ":lua insertWikiLinkWithCurrentWorkingDirectoryPath()<cr>", { noremap = true, buffer = true })
