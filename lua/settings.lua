--[[
  This is how you do a multiline string
--]]

-- [[ Setting options ]]
-- See `:help vim.opt`

-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

-- Tabs and line endings
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.foldmethod = 'indent'

-- set color of cursor 
-- see :h highlight :h highlight-group
vim.cmd 'hi Cursor guibg=#626262'

-- Show filename in terminal title
vim.opt.title = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Grep
vim.opt.grepprg = 'rg --vimgrep --no-heading --smart-case'
vim.opt.grepformat = '%f:%l:%c:%m'

-- Use pwsh as terminal/ shell --
vim.opt.shell = 'pwsh.exe'
vim.opt.shellcmdflag = '-OutputFormat Text -nol -c'
vim.opt.shellquote = ''
vim.opt.shellxquote = ''

-- Sync clipboard between OS and Neovim.
    --  Schedule the setting after `UiEnter` because it can increase startup-time.
    --  Remove this option if you want your OS clipboard to remain independent.
    --  See `:help 'clipboard'`
vim.schedule(function()
    vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor. See `:help 'list'` and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 8
