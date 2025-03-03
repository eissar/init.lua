-- Set <space> as the leader key (See `:help mapleader`)
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

--[[ temp fix for SHADA Issue:
  <https://github.com/neovim/neovim/issues/8587>
  ```powershell
   ls C:\Users\eshaa\AppData\Local\nvim-data\shada\main.shada.tmp* | del
  ```
]]
--

--[[ 
    fix for nvim-treesitter[lua]: Failed to execute the following command:
    update git?
    doesn't work. 
]]
--
-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = false

--#region install Lazy plugin manager
--  See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
    if vim.v.shell_error ~= 0 then
        error('Error cloning lazy.nvim:\n' .. out)
    end
end
---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)
--#endregion

--#region Manage Plugins
--[[
--
  To check the current status of your plugins, run
    :Lazy

  You can press `?` in this menu for help. Use `:q` to close the window

  To update plugins you can run
    :Lazy update
]]
--
---@diagnostic disable-next-line: undefined-field
require('lazy').setup({
    {
        'tpope/vim-fugitive',
    },
    {
        'kiyoon/jupynium.nvim',
        --opts = {},
        --build = 'uv venv $CLOUD_DIR/Application_Files/.envs/jupynium/ && --python=3.13 && uv pip install . --python=$CLOUD_DIR/Application_Files/.envs/jupynium/bin/python',
        build = 'uv pip install . --python=C:/Users/eshaa/Dropbox/Application_Files/.envs/jupynium/bin/python',
    },
    {
        --'Decodetalkers/csharpls-extended-lsp.nvim',
    },

    -- Neovim plugin to animate the cursor with a smear (subtle)
    {
        'sphamba/smear-cursor.nvim',
        opts = {
            cursor_color = '#CDCECF',
            stiffness = 0.8,
            trailing_stiffness = 0.62,
            distance_stop_animating = 0.5,
            hide_target_hack = false,
        },
    },
    -- Detect tabstop and shiftwidth automatically,
    -- { 'tpope/vim-sleuth', },
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    {
        'lewis6991/gitsigns.nvim',
        opts = {
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
            },
        },
    },
    -- Show pending keybinds as they are typed
    {
        'folke/which-key.nvim',
        event = 'VimEnter', -- Sets the loading event to 'VimEnter'
        config = function() -- This is the function that runs, AFTER loading
            require('which-key').setup()

            -- Document existing key chains
            require('which-key').add {
                { '<leader>c', group = '[C]ode' },
                { '<leader>d', group = '[D]ocument' },
                { '<leader>r', group = '[R]ename' },
                { '<leader>s', group = '[S]earch' },
                { '<leader>w', group = '[W]orkspace' },
                { '<leader>t', group = '[T]oggle' },
                { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
                { '<leader>p', group = '[P]roject' },
            }
        end,
    },
    -- Fuzzy Finder (files, lsp, etc)
    {
        'nvim-telescope/telescope.nvim',
        event = 'VimEnter',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            { -- If encountering errors, see telescope-fzf-native README for installation instructions
                'nvim-telescope/telescope-fzf-native.nvim',

                -- `build` is used to run some command when the plugin is installed/updated.
                -- This is only run then, not every time Neovim starts up.
                build = 'make',

                -- `cond` is a condition used to determine whether this plugin should be
                -- installed and loaded.
                cond = function()
                    return vim.fn.executable 'make' == 1
                end,
            },
            { 'nvim-telescope/telescope-ui-select.nvim' },

            -- Useful for getting pretty icons, but requires a Nerd Font.
            { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
        },
        config = function()
            -- The easiest way to use Telescope, is to start by doing something like:
            --  :Telescope help_tags
            --
            -- After running this command, a window will open up and you're able to
            -- type in the prompt window. You'll see a list of `help_tags` options and
            -- a corresponding preview of the help.
            --
            -- Two important keymaps to use while in Telescope are:
            --  - Insert mode: <c-/>
            --  - Normal mode: ?
            --
            -- This opens a window that shows you all of the keymaps for the current
            -- Telescope picker. This is really useful to discover what Telescope can
            -- do as well as how to actually do it!

            -- [[ Configure Telescope ]]
            -- See `:help telescope` and `:help telescope.setup()`
            require('telescope').setup {
                -- You can put your default mappings / updates / etc. in here
                --  `:help telescope.setup()`
                --
                -- defaults = {
                --   mappings = {
                --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
                --   },
                -- },
                -- pickers = {}
                extensions = {
                    ['ui-select'] = {
                        require('telescope.themes').get_dropdown(),
                    },
                },
            }

            -- Enable Telescope extensions if they are installed
            pcall(require('telescope').load_extension, 'fzf')
            pcall(require('telescope').load_extension, 'ui-select')
        end,
    },
    -- Highlight todo, notes, etc in comments
    {
        'folke/todo-comments.nvim',
        event = 'VimEnter',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = { signs = false },
    },
    -- Highlight, edit, and navigate code
    {
        'nvim-treesitter/nvim-treesitter',
        opts = {
            compilers = { 'zig', 'gcc', 'clang' },
            ensure_installed = { 'bash', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
            -- Autoinstall languages that are not installed
            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,

            -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
            auto_install = true,
            highlight = {
                enable = true,
                -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
                --  If you are experiencing weird indenting issues, add the language to
                --  the list of additional_vim_regex_highlighting and disabled languages for indent.
                additional_vim_regex_highlighting = { 'ruby' },
            },
            indent = { enable = true, disable = { 'ruby' } },
            -- run = ':TSUpdate',
        },
        config = function(_, opts)
            -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

            --#startRegion Override `select_rm_file_cmd`
            -- local augroup = vim.api.nvim_create_augroup('TSInstallOverride', { clear = true })
            -- vim.api.nvim_create_autocmd('BufReadPost', {
            --     group = augroup,
            --     pattern = '*', -- Run for all file types
            --     once = true, -- Only run once per Neovim session
            --     callback = function()

            --         ---@diagnostic disable-next-line: duplicate-set-field
            --         require('nvim-treesitter.shell_command_selectors').select_install_rm_cmd = function(file, info_msg)
            --             if vim.fn.has 'win32' == 1 then
            --                 return {
            --                     cmd = 'pwsh.exe',
            --                     opts = {
            --                         -- Add the '/F' flag to force deletion
            --                         args = { '-c', 'Remove-Item', '-Path', file, '-Force', '-Recurse' },
            --                     },
            --                     info = info_msg,
            --                     err = 'Could not delete ' .. file,
            --                 }
            --             end
            --         end
            --     end,
            -- })
            --#endRegion

            ---@diagnostic disable-next-line: missing-fields
            require('nvim-treesitter.configs').setup(opts)

            require('nvim-treesitter.install').prefer_git = false
            -- There are additional nvim-treesitter modules that you can use to interact
            -- with nvim-treesitter. You should go explore a few and see what interests you:
            --
            --    - TODO: Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
            --
            --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
            --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
        end,
    },
    -- colorscheme
    {
        -- You can easily change to a different colorscheme.
        -- Change the name of the colorscheme plugin below, and then
        -- change the command in the config to whatever the name of that colorscheme is.
        --
        -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
        'EdenEast/nightfox.nvim',
        priority = 1000, -- Make sure to load this before all the other start plugins.
        init = function()
            -- Load the colorscheme here.
            vim.cmd.colorscheme 'nightfox'
            -- You can configure highlights by doing something like:
            vim.cmd.hi 'Comment gui=none'
        end,
    },
    -- interactive repl for configured languages
    { 'Vigemus/iron.nvim' },
    {
        'olimorris/codecompanion.nvim',
        -- if you have, problems, replace vim.cmd.undojoin() with if vim.fn.undotree().seq_cur > 1 then vim.cmd.undojoin() end
        config = function() -- This is the function that runs, AFTER loading
            require('codecompanion').setup {
                display = {
                    diff = {
                        provider = 'mini_diff',
                    },
                },
                strategies = {
                    chat = {
                        adapter = 'ollama',
                    },
                    inline = {
                        adapter = 'ollama',
                    },
                    suggestion = {
                        auto_trigger = true,
                    },
                },
                adapters = {
                    ollama = function()
                        return require('codecompanion.adapters').extend('ollama', {
                            -- https://github.com/jcorbin/home/blob/0e18734fcd559a6c3093dd55fe5be75270bd255b/.config/nvim/lua/plugins/ai.lua#L13
                            env = {
                                url = 'http://workstation:11434',
                                chat_url = '/v1/chat/completions',
                            },
                            schema = {
                                -- huggingface.co/bartowski/Qwen2.5-Coder-32B-Instruct-GGUF:latest, codellama:7b-code, phi4:latest, llama3.3:latest, llama3.2:latest
                                name = 'phi4',
                                model = {
                                    default = 'phi4',
                                },
                            },
                        })
                    end,
                },
            }
        end,
    },
    -- automatically add plugins, configuration, etc from `lua/lazy-plugins/*.lua`
    {
        import = 'lazy-plugins', -- './lua/lazy-plugins/'
        -- Status Line: ./lua/lazy-plugins/mini-nvim.lua
    },

    ---@diagnostic disable-next-line: missing-fields
}, {
    ui = {
        -- If you are using a Nerd Font: set icons to an empty table which will use the
        -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
        icons = vim.g.have_nerd_font and {} or {
            cmd = '⌘',
            config = '🛠',
            event = '📅',
            ft = '📂',
            init = '⚙',
            keys = '🗝',
            plugin = '🔌',
            runtime = '💻',
            require = '🌙',
            source = '📄',
            start = '🚀',
            task = '📌',
            lazy = '💤 ',
        },
    },
    change_detection = {
        -- automatically check for config file changes and reload the ui
        enabled = true,
        notify = false, -- get a notification when changes are found
        -- custom notification is configured in ./lua/autocmd.lua
    },
})
--#endregion

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

-- just throwing this in here  TODO: move
vim.api.nvim_create_user_command('PopupWindow', PopupWindow, {})

require 'remap' -- './lua/remap.lua'
require 'settings' -- './lua/settings.lua'
require 'autocmd' -- './lua/autocmd.lua'
require 'plugins.snippets' -- './lua/plugins/snippets.lua'
require 'plugins.iron-nvim' -- './lua/plugins/snippets.lua'
