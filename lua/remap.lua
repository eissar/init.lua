-- [[ Basic Keymaps ]] See `:help vim.keymap.set()`

-- There is a popular mapping that will show the :ls result above a prompt: <https://vi.stackexchange.com/questions/14829/close-multiple-buffers-interactively>
vim.keymap.set('n', '<leader>ls', ':ls<CR>:b<space>')
vim.api.nvim_set_keymap('n', '<C-v>', '"+p', { noremap = true })

-- goto start/end of line
vim.api.nvim_set_keymap('n', 'gs', '^', { noremap = true, silent = true, desc = '[G]oto Start' })
vim.keymap.set('n', 'ge', '$') -- go to end of line
-- Also consider, Goto Append or Goto Insert gA / gI to mirror insert/ append

vim.api.nvim_set_keymap('n', '<M-j>', ':m +1<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<M-k>', ':m -2<cr>', { noremap = true, silent = true })

-- vim.keymap.set("n", "<leader>po",":lua showPopupPickList('/OneDrive/Catalog/note-taking.notebook/hom.md')<cr>", { noremap = true, silent = true })

-- netrw sucks so open file under cursor. gX until I find a better hotkey.
vim.keymap.set('n', 'gX', function()
    local filepath = vim.fn.expand '<cfile>:p'
    local modified_path = filepath:gsub('\\', '/')
    vim.cmd('!start "" "' .. modified_path .. '"')
end, { desc = 'Open file under cursor, (not really working)' })

vim.keymap.set('n', '<leader>ts', function()
    -- Get row and column cursor,
    -- use unpack because it's a tuple.
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    local current_time = os.date '%I:%M %p' -- Get current time in 12-hour format with AM/PM
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { tostring(current_time) })
end, { desc = 'Insert timestamp' })

-- Filename Completion
vim.keymap.set('i', '<C-f>', '<C-x><C-f>', { desc = '[F]ilename completion' })

-- vim.api.nvim_set_keymap('n',
--'<leader><Ctrl>v',":lua insertFilename()<cr>",
--{ noremap = true, silent = true })

--[[ Lua function keybindings ]]
vim.api.nvim_set_keymap('n', 'gX', ':lua getNodeAsUrl()<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>prf', ':lua PrintFile()<cr>', { noremap = true, silent = true, desc = 'Print markdown file and open in webbrowser.' })
vim.api.nvim_set_keymap('n', '<leader>id', ':lua insertDate()<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ifn', ':lua insertFilename()<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>it', ':lua InsertAbbreviatedTime()<cr>', { noremap = true, silent = true })

-- Keybinding for opening Ex file browser
vim.keymap.set('n', '<leader>pv', ':Ex<cr>', { noremap = true, silent = true, desc = '[P]roject [V]iew' })
-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>gq', ':copen<cr>', { desc = '[G]oto [Q]uickfix' })

vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { desc = '[G]oto [D]efinition' })
vim.keymap.set('n', '<leader>gD', vim.lsp.buf.declaration, { desc = '[G]oto [D]eclaration' })
vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, { desc = '[G]oto [I]mplementation' })

--vim.keymap.set('n', '<leader>ow', vim.cmd 'only', { desc = '[O]nly [I]mplementation' })
vim.keymap.set('n', '<leader>zo', function()
    -- Save the current cursor position
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    -- Get the current file's path.  `%` expands to the current file path.
    local current_file = vim.fn.expand '%'

    -- Check if we have a filename (not an unnamed buffer)
    if current_file ~= '' then
        -- Open the current file in a new tab.
        vim.cmd('tabnew ' .. current_file)

        -- Restore the cursor position in the *new* tab.
        vim.api.nvim_win_set_cursor(0, { row, col })
        vim.cmd 'normal! zz' -- make cursor centered
    end
end, { noremap = true, desc = '[Z]oom [O]pen' })

vim.keymap.set('n', '<leader>zc', ':tabclose<cr>', { desc = '[Z]oom [C]lose' })

-- marks

-- Exit terminal mode in the builtin terminal. This won't work in all terminal emulators/tmux/etc.
--  You normally need to press <C-\><C-n>
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- open powershell in a new tab
vim.keymap.set('n', '<leader>pwsh', function()
    vim.cmd [[:vsp term://pwsh -nol]]
end, { desc = 'PowerShell' })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
--vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
--vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
--vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
--vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Telescope bindings; see `:help telescope.builtin`
do
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>ps', builtin.live_grep, { desc = '[P]roject [S]earch' })
    vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = '[P]roject [F]iles' })

    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<leader>sm', builtin.marks, { desc = '[S]earch [M]arks' })

    -- vim.keymap.set('n', '<C-p>', builtin.git_files, {})
    -- Slightly advanced example of overriding default behavior and theme
    vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
        })
    end, { desc = '[/] Fuzzily search in current buffer' })

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
        }
    end, { desc = '[S]earch [/] in Open Files' })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })

    vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })
    -- our picker function: colors
    local colors = function(opts)
        local pickers = require 'telescope.pickers'
        local finders = require 'telescope.finders'
        local conf = require('telescope.config').values
        opts = opts or {}
        pickers
            .new(opts, {
                prompt_title = 'colors',
                finder = finders.new_table {
                    results = GetMarkdownCatalog(),
                },
                sorter = conf.generic_sorter(opts),
            })
            :find()
    end
    vim.keymap.set('n', '<leader>sc', colors)
end

-- CodeCompanionChat <https://github.com/search?q=repo%3Aolimorris%2Fcodecompanion.nvim%20keymap&type=code>
vim.keymap.set('n', '<A-c>', '<cmd>CodeCompanionChat Toggle<cr>', { desc = 'CodeCompanion' })
-- vim.keymap.set("n", "<C-a>", "<cmd>CodeCompanionActions<cr>")
-- vim.keymap.set("v", "<C-a>", "<cmd>CodeCompanionActions<cr>")
-- vim.keymap.set("n", "<M-a>", "<cmd>CodeCompanionChat Toggle<cr>")
-- vim.keymap.set("v", "<M-a>", "<cmd>CodeCompanionChat Toggle<cr>")
-- vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>")
vim.cmd [[cab cc CodeCompanion]]

-- # KEYMAPS SET IN OTHER FILES:
-- <leader>
--
-- map commands in lua/lazy-plugins/lsp.lua
