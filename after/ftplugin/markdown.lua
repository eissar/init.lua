require 'plugins.markdown-functions'
-- vim.api.nvim_set_keymap('v', '<C-k>', ':lua MarkdownLink()<cr>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<C-k>', ':lua InsertMarkdownLink()<cr>', { noremap = true, silent = true })

-- vim.api.nvim_set_keymap('n', '<leader>prm', ':lua openMarkdownInBrowser()<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>prm', ':lua OpenMarkdownInBrowser()<cr>', { noremap = true, silent = true })

-- require('telescope.themes').get_dropdown {
--             winblend = 10,
--             previewer = false,
--         }

vim.keymap.set('n', '<leader>gh', function()
    local make_entry = require 'telescope.make_entry'
    local entry_display = require 'telescope.pickers.entry_display'
    local actions = require 'telescope.actions'
    local action_state = require 'telescope.actions.state'
    local themes = require 'telescope.themes'

    -- Create ONE displayer with a ratio (80% left, 20% right)
    local displayer = entry_display.create {
        separator = ' ',
        items = {
            {
                width = function(_, cols)
                    return math.floor(cols * 0.8)
                end,
            },
            { remaining = true, right_justify = true },
        },
    }

    -- Custom entry maker for LSP symbols
    local entry_maker_lsp_symbols = function(entry)
        local default_maker = make_entry.gen_from_lsp_symbols()
        local entry_tbl = default_maker(entry)
        if entry_tbl then
            local filename_short = vim.fn.fnamemodify(entry.filename or '', ':t')
            local lnum = (entry.lnum or 0) + 1
            local display_text = entry.text:gsub('^%[.-%]%s*', '')
            local right_col = string.format('%s:%d', filename_short, lnum)
            entry_tbl.display = function()
                return displayer { display_text, right_col }
            end
            entry_tbl.filename = entry.filename
        end
        return entry_tbl
    end

    -- Function to auto-scroll previewer
    local function scroll_previewer(prompt_bufnr)
        local picker = action_state.get_current_picker(prompt_bufnr)
        if picker and picker.previewer then
            local preview_bufnr = picker.previewer.state and picker.previewer.state.bufnr
            if preview_bufnr then
                vim.api.nvim_buf_call(preview_bufnr, function()
                    vim.opt_local.scrolloff = 0
                    vim.cmd 'normal! zt'
                end)
            end
        end
    end

    -- Telescope options
    local opts = themes.get_dropdown {
        layout_config = { width = 0.8, height = 0.55 },
        entry_maker = entry_maker_lsp_symbols,
        attach_mappings = function(prompt_bufnr, map)
            -- Helper to bind movement with auto-scroll
            local function bind_move(key, move_func)
                map('i', key, function()
                    move_func(prompt_bufnr)
                    vim.schedule(function()
                        scroll_previewer(prompt_bufnr)
                    end)
                end)
                map('n', key, function()
                    move_func(prompt_bufnr)
                    vim.schedule(function()
                        scroll_previewer(prompt_bufnr)
                    end)
                end)
            end

            bind_move('<C-n>', actions.move_selection_next)
            bind_move('<C-p>', actions.move_selection_previous)
            bind_move('j', actions.move_selection_next)
            bind_move('k', actions.move_selection_previous)

            -- Scroll on initial load
            vim.schedule(function()
                scroll_previewer(prompt_bufnr)
            end)
            return true
        end,
    }

    require('telescope.builtin').lsp_document_symbols(opts)
end, { desc = '[G]et [H]eadings' })
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
