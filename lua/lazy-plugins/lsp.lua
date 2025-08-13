return {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
            library = {
                -- Load luvit types when the `vim.uv` word is found
                { path = 'luvit-meta/library', words = { 'vim%.uv' } },
            },
        },
    },
    {
        'Bilal2453/luvit-meta',
        lazy = true,
    },

    -- Main LSP Configuration
    {
        'neovim/nvim-lspconfig',
        opts = {
            inlay_hints = { enabled = true },
        },
        dependencies = {
            -- Automatically install LSPs and related tools to stdpath for Neovim
            { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
            'williamboman/mason-lspconfig.nvim',
            'WhoIsSethDaniel/mason-tool-installer.nvim',

            -- Useful status updates for LSP.
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            { 'j-hui/fidget.nvim', opts = {} },

            -- Allows extra capabilities provided by nvim-cmp
            'hrsh7th/cmp-nvim-lsp',
        },
        config = function()
            --[[
        **Brief aside: What is LSP?**
        LSP is an initialism you've probably heard, but might not understand what it is.

        LSP stands for Language Server Protocol. It's a protocol that helps editors
        and language tooling communicate in a standardized fashion.
        In general, you have a "server" which is some tool built to understand a particular
        language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
        (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
        processes that communicate with some "client" - in this case, Neovim!

        LSP provides Neovim with features like:
        - Go to definition
        - Find references
        - Autocompletion
        - Symbol Search
        - and more!

        Thus, Language Servers are external tools that must be installed separately from
        Neovim. This is where `mason` and related plugins come into play.
        If you're wondering about lsp vs treesitter, you can check out the wonderfully
        and elegantly composed help section, `:help lsp-vs-treesitter`

        This function gets run when an LSP attaches to a particular buffer.
        That is to say, every time a new file is opened that is associated with
        an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
        function will be executed to configure the current buffer
      ]]
            --
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc)
                        vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end

                    -- Jump to the definition of the word under your cursor.
                    --  This is where a variable was first declared, or where a function is defined, etc.
                    --  To jump back, press <C-t>.
                    map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

                    -- Find references for the word under your cursor.
                    map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

                    -- Jump to the implementation of the word under your cursor.
                    --  Useful when your language has ways of declaring types without an actual implementation.
                    map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

                    -- Jump to the type of the word under your cursor.
                    --  Useful when you're not sure what type a variable is and you want to see
                    --  the definition of its *type*, not where it was *defined*.
                    map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

                    -- Fuzzy find all the symbols in your current document.
                    --  Symbols are things like variables, functions, types, etc.
                    map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

                    -- Fuzzy find all the symbols in your current workspace.
                    --  Similar to document symbols, except searches over your entire project.
                    map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

                    -- Rename the variable under your cursor.
                    --  Most Language Servers support renaming across files, etc.
                    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

                    -- Execute a code action, usually your cursor needs to be on top of an error
                    -- or a suggestion from your LSP for this to activate.
                    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

                    -- WARN: This is not Goto Definition, this is Goto Declaration.
                    --  For example, in C this would take you to the header.
                    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

                    -- The following two autocommands are used to highlight references of the
                    -- word under your cursor when your cursor rests there for a little while.
                    --    See `:help CursorHold` for information about when this is executed
                    --
                    function GetTableLen(tbl)
                        local getN = 0
                        for n in pairs(tbl) do
                            getN = getN + 1
                        end
                        return getN
                    end

                    -- When you move your cursor, the highlights will be cleared (the second autocommand).
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and type(client.name) == 'string' then
                        local b = vim.api.nvim_get_current_buf()
                        local clients = vim.lsp.get_clients { bunr = b }
                        -- client.name for client in clients
                        local names_len = 0
                        local names = {}
                        for _, c in ipairs(clients) do
                            local nm = c.name
                            if nm == 'lua_ls' or nm == 'gopls' then
                                return
                            else
                                names_len = names_len + 1
                                -- filter only LSPs that don't show any notification when they're loaded
                                table.insert(names, nm)
                            end
                        end

                        local clean_names = ''
                        if names_len == 1 then
                            clean_names = names[1]
                        else
                            clean_names = table.concat(names, ', ')
                        end
                        require('fidget').notify([[Lsp Loaded: ]] .. clean_names, vim.log.levels.INFO, { ttl = 0 })
                    end

                    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })

                        vim.api.nvim_create_autocmd('LspDetach', {
                            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                            end,
                        })
                    end

                    -- The following code creates a keymap to toggle inlay hints in your
                    -- code, if the language server you are using supports them
                    --
                    -- This may be unwanted, since they displace some of your code
                    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                        map('<leader>th', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                        end, '[T]oggle Inlay [H]ints')
                    end
                end,
            })

            -- LSP servers and clients are able to communicate to each other what features they support.
            --  By default, Neovim doesn't support everything that is in the LSP specification.
            --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
            --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
            }
            capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

            -- Enable the following language servers
            --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
            --
            --  Add any additional override configuration in the following tables. Available keys are:
            --  - cmd (table): Override the default command used to start the server
            --  - filetypes (table): Override the default list of associated filetypes for the server
            --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
            --  - settings (table): Override the default settings passed when initializing the server.
            --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
            local servers = {
                powershell_es = {
                    capabilities = capabilities,
                    bundle_path = vim.fn.stdpath 'data' .. '/mason/packages/powershell-editor-services', -- ~\Dropbox\Application_Files\lsp\PowerShellEditorServices
                    shell = 'pwsh.exe',
                    single_file_support = true,
                    settings = {
                        -- <https://github.com/PowerShell/PSScriptAnalyzer/blob/a744b6cfb6815d8f8fcc1901e617081580751155/Engine/Settings.cs#L40>
                        powershell = {
                            scriptAnalysis = {
                                -- <https://github.com/PowerShell/PowerShellEditorServices/blob/e26f172efa6ee6aef1de0f64b7f2d0fbbc5d22cd/src/PowerShellEditorServices/Services/Workspace/LanguageServerSettings.cs#L61>
                                enable = true,
                                -- <https://github.com/PowerShell/PowerShellEditorServices/blob/e26f172efa6ee6aef1de0f64b7f2d0fbbc5d22cd/src/PowerShellEditorServices/Services/Workspace/LanguageServerSettings.cs#L62>
                                settingsPath = os.getenv 'CLOUD_DIR' .. [[/Documents/Powershell/PSScriptAnalyzerSettings.psd1"]], -- '~\Dropbox\Documents\Powershell\PSScriptAnalyzerSettings.psd1'
                            },
                            codeFormatting = {
                                --enable = false
                                -- [[ You can get more code formatting settings here: -- https://github.com/PowerShell/PowerShellEditorServices/blob/41fce39f491d5d351b4ac5864e89857ec070e107/src/PowerShellEditorServices/Services/Workspace/LanguageServerSettings.cs ]]
                                Preset = 'OTBS',
                                useCorrectCasing = true,
                                openBraceOnSameLine = true,
                            },
                            -- settingsPath = os.getenv 'CLOUD_DIR' .. [[/Documents/Powershell/PSScriptAnalyzerSettings.psd1]], -- '~\Dropbox\Documents\Powershell\PSScriptAnalyzerSettings.psd1'
                            -- },

                            -- pwsh.exe -NoLogo -NoProfile -Command & 'C:\Users\eshaa\AppData\Local\nvim-data/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1'
                            --command = 'pwsh',
                            --args = { '-NoProfile', '-Command', '[Console]::In.ReadToEnd() | Invoke-Formatter' },
                            -- command = 'pwsh',
                            -- args = {
                            --     '-NoProfile',
                            --     '-Command',
                            --     "if(!(Get-Module -ListAvailable PSScriptAnalyzer -ErrorAction SilentlyContinue)){Import-Module '~/AppData/Local/nvim-data/mason/packages/powershell-editor-services/PSScriptAnalyzer/*/PSScriptAnalyzer.psd1' -ErrorAction SilentlyContinue}; [Console]::In.ReadToEnd() | Invoke-Formatter -Settings @{Rules = @{PSUseConsistentIndentation=@{IndentationSize=4;Kind='space'};PSPlaceOpenBrace=@{Enable=$true;OnSameLine=$true;}}}",
                            -- },
                        },
                    },
                },
                --[[
                    From <https://github.com/PowerShell/PowerShellEditorServices/blob/main/docs/guide/getting_started.md#neovim>

                    You can also set the bundled PSScriptAnalyzer's custom rule path like so:
                    local custom_settings_path = home_directory .. '/PSScriptAnalyzerSettings.psd1'
                    require('lspconfig')['powershell_es'].setup
                    bundle_path = bundle_path,
                    on_attach = on_attach,
                    settings = { powershell = { scriptAnalysis = { settingsPath = custom_settings_path } } }
                --]]
                marksman = {},
                gopls = {
                    settings = {
                        gofumpt = true,
                        analyses = {
                            nilness = true,
                            unusedparams = true,
                            unusedwrite = true,
                            useany = true,
                        },
                        hints = {
                            assignVariableTypes = true,
                            compositeLiteralFields = true,
                            compositeLiteralTypes = true,
                            constantValues = true,
                            functionTypeParameters = true,
                            parameterNames = true,
                            rangeVariableTypes = true,
                        },
                        analyses = {
                            nilness = true,
                            unusedparams = true,
                            unusedwrite = true,
                            useany = true,
                        },
                        experimentalPostfixCompletions = true,
                        staticcheck = true,
                        linksInHover = 'gopls',
                        usePlaceholders = true,
                        directoryFilters = { '-.git', '-.vscode', '-.idea', '-.vscode-test', '-node_modules' },
                    },
                },
                pyright = {
                    single_file_support = true,
                },
                jsonls = {
                    settings = {
                        schemas = {
                            {
                                fileMatch = { 'deno.json', 'deno.jsonc' },
                                url = 'https://github.com/denoland/deno/blob/main/cli/schemas/config-file.v1.json',
                            },
                        },
                    },
                },
                -- sqls = {
                --     single_file_support = true,
                --     filetypes = { 'sql', 'mssql' },
                --     on_attach = function(client)
                --         client.server_capabilities.documentFormattingProvider = false
                --         client.server_capabilities.documentRangeFormattingProvider = false
                --     end,
                --     --     -- do not configure here. edit config at: ['~\.config\sqls\config.yml'] connections = { alias = "sakila_master", driver = "sqlite3", dataSourceName = "file:/Users/eshaa/sakila_master.db", }
                -- },
                -- tsserver = {},
                eslint = {
                    filetypes = { 'javascript' },
                    --  filetypes (table): Override the default list of associated filetypes for the server
                },

                lua_ls = {
                    -- cmd = {...},
                    -- filetypes = { ...},
                    -- capabilities = {},
                    settings = {
                        Lua = {
                            completion = {
                                callSnippet = 'Replace',
                            },
                            format = {
                                enable = true,
                                defaultConfig = {
                                    ---@type "keep"|"always"|"same_line"|"replace_with_newline"|"never"
                                    end_statement_with_semicolon = 'always',
                                    quote_style = 'single',
                                },
                            },
                            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                            -- diagnostics = { disable = { 'missing-fields' } },
                        },
                    },
                },
                html = {},
                denols = {
                    root_dir = require('lspconfig').util.root_pattern { 'deno.json', 'deno.jsonc' },
                    settings = {},
                    init_options = {
                        -- lint = true,
                        unstable = true,
                    },
                },
                -- ltex = { bundle_path = 'C:/Users/eshaa/Downloads/ltex-ls-16.0.0-windows-x64', },
                -- lemminx = {},
                -- clangd = {},
                -- :h omnisharp
                --omnisharp = {
                --    cmd = { 'C:/Users/eshaa/Dropbox/Application_Files/lsp/omnisharp/OmniSharp.exe', '--languageserver', '--hostPID', tostring(vim.fn.getpid()) },
                --    settings = {
                --        FormattingOptions = {
                --            -- Enables support for reading code style, naming convention and analyzer
                --            -- settings from .editorconfig.
                --            EnableEditorConfigSupport = true,
                --            -- Specifies whether 'using' directives should be grouped and sorted during
                --            -- document formatting.
                --            OrganizeImports = nil,
                --        },
                --        RoslynExtensionsOptions = {
                --            -- Enables support for roslyn analyzers, code fixes and rulesets.
                --            EnableAnalyzersSupport = nil,
                --            enableDecompilationSupport = true,
                --            enableImportCompletion = true,
                --            enableAnalyzersSupport = true,
                --            diagnosticWorkersThreadCount = 8,
                --        },
                --    },
                --},
                --csharp_ls = {
                --    handlers = {
                --        ['textDocument/definition'] = require('csharpls_extended').handler,
                --        ['textDocument/typeDefinition'] = require('csharpls_extended').handler,
                --    },
                --    --cmd = { csharp_ls },
                --},
                fsautocomplete = {
                    cmd = { 'fsautocomplete', '--adaptive-lsp-server-enabled' },
                    settings = {
                        FSharp = {
                            EnableReferenceCodeLens = true,
                            ExternalAutocomplete = true,
                            InterfaceStubGeneration = true,
                            InterfaceStubGenerationMethodBody = 'failwith "Not Implemented"',
                            InterfaceStubGenerationObjectIdentifier = 'this',
                            Linter = true,
                            RecordStubGeneration = true,
                            RecordStubGenerationBody = 'failwith "Not Implemented"',
                            ResolveNamespaces = true,
                            SimplifyNameAnalyzer = true,
                            UnionCaseStubGeneration = true,
                            UnionCaseStubGenerationBody = 'failwith "Not Implemented"',
                            UnusedDeclarationsAnalyzer = true,
                            UnusedOpensAnalyzer = true,
                            UseSdkScripts = true,
                            keywordsAutocomplete = true,
                        },
                    },
                },
            }

            --[[
                Ensure the servers and tools above are installed
                To check the current status of installed tools and/or manually install
                other tools, you can run
                  :Mason
                You can press `g?` for help in this menu.
            --]]
            require('mason').setup()

            -- You can add other tools here that you want Mason to install
            -- for you, so that they are available from within Neovim.
            local ensure_installed = vim.tbl_keys(servers or {})
            vim.list_extend(ensure_installed, {
                'stylua', -- formatter for lua
                -- 'sleek', --formatter for sql
                'sqlfluff', --linter for sql
                'prettierd', -- js formatter
            })
            require('mason-tool-installer').setup { ensure_installed = ensure_installed }

            ---@diagnostic disable-next-line: missing-fields
            require('mason-lspconfig').setup {
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        -- This handles overriding only values explicitly passed
                        -- by the server configuration above. Useful when disabling
                        -- certain features of an LSP (for example, turning off formatting for tsserver)
                        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                        require('lspconfig')[server_name].setup(server)
                    end,
                },
            }
        end,
    },

    { -- Autoformat
        'stevearc/conform.nvim',
        event = { 'BufWritePre' },
        cmd = { 'ConformInfo' },
        keys = {
            {
                '<leader>f',
                function()
                    require('conform').format { async = true, lsp_fallback = true }
                end,
                mode = '',
                desc = '[F]ormat buffer',
            },
        },
        opts = {
            log_level = vim.log.levels.TRACE,
            notify_on_error = true,
            format_on_save = function(bufnr)
                -- Disable "format_on_save lsp_fallback" for languages that don't
                -- have a well standardized coding style. You can add additional
                -- languages here or re-enable it for the disabled ones.
                local disable_filetypes = { c = true, cpp = true, templ = true }
                return {
                    timeout_ms = 500,
                    lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
                }
            end,
            formatters_by_ft = {
                lua = { 'stylua' },
                -- sql = { 'sleek' }, -- works
                sql = { 'sqlfluff' },
                -- Conform can also run multiple formatters sequentially
                -- You can use 'stop_after_first' to run the first available formatter from the list
                javascript = { 'prettierd', 'prettier', stop_after_first = true },
            },
            -- <https://github.com/m0lson84/neovim/blob/2f01d16fe9ac2a736428dec56bf23edd3f10d3c5/lua/plugins/linters/sqlfluff.lua#L24>
            formatters = {
                sqlfluff = {
                    -- sqlfluff = { args = { 'fix', '--dialect', 'ansi', '-' } },
                    -- args = { 'fix', '--show-lint-violations', '-p', '6', '--ignore', 'parsing', '-' },
                    -- args = { 'fix', '--ignore', 'parsing', '-' },
                    args = { 'fix', '-' },
                    exit_codes = { 0, 1 }, -- TODO: add to conform settings
                    stdin = true,
                },
            },
        },
    },

    { -- Autocompletion
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            {
                'L3MON4D3/LuaSnip',
                build = (function()
                    -- Build Step is needed for regex support in snippets.
                    -- This step is not supported in many windows environments.
                    -- Remove the below condition to re-enable on windows.
                    if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
                        return
                    end
                    return 'make install_jsregexp'
                end)(),
                dependencies = {
                    -- `friendly-snippets` contains a variety of premade snippets.
                    --    See the README about individual language/framework/plugin snippets:
                    --    https://github.com/rafamadriz/friendly-snippets
                    -- {
                    --   'rafamadriz/friendly-snippets',
                    --   config = function()
                    --     require('luasnip.loaders.from_vscode').lazy_load()
                    --   end,
                    -- },
                },
            },
            'saadparwaiz1/cmp_luasnip',

            -- Adds other completion capabilities.
            --  nvim-cmp does not ship with all sources by default. They are split
            --  into multiple repos for maintenance purposes.
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-path',
        },
        config = function()
            -- See `:help cmp`
            local cmp = require 'cmp'
            local luasnip = require 'luasnip'
            luasnip.config.setup {}

            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                completion = { completeopt = 'menu,menuone,noinsert' },
                view = { docs = { auto_open = false } },
                experimental = {
                    ghost_text = true,
                },

                -- For an understanding of why these mappings were
                -- chosen, you will need to read `:help ins-completion`
                --
                -- No, but seriously. Please read `:help ins-completion`, it is really good!
                mapping = cmp.mapping.preset.insert {
                    -- Select the [n]ext item
                    ['<C-n>'] = cmp.mapping.select_next_item(),

                    -- Select the [p]revious item
                    ['<C-p>'] = cmp.mapping.select_prev_item(),

                    -- Scroll the documentation window [b]ack / [f]orward
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),

                    -- Accept ([y]es) the completion.
                    --  This will auto-import if your LSP supports it.
                    --  This will expand snippets if the LSP sent a snippet.
                    ['<C-y>'] = cmp.mapping.confirm { select = true },

                    ['<C-g>'] = function()
                        if cmp.visible_docs() then
                            return cmp.close_docs()
                        end

                        return cmp.open_docs()
                    end,

                    -- Manually trigger a completion from nvim-cmp.
                    --  Generally you don't need this, because nvim-cmp will display
                    --  completions whenever it has completion options available.
                    ['<C-Space>'] = cmp.mapping.complete {},

                    -- Think of <c-l> as moving to the right of your snippet expansion.
                    --  So if you have a snippet that's like:
                    --  function $name($args)
                    --    $body
                    --  end
                    --
                    -- <c-l> will move you to the right of each of the expansion locations.
                    -- <c-h> is similar, except moving you backwards.
                    ['<C-l>'] = cmp.mapping(function()
                        if luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        end
                    end, { 'i', 's' }),
                    ['<C-h>'] = cmp.mapping(function()
                        if luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        end
                    end, { 'i', 's' }),

                    -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
                    --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
                },
                sources = {
                    {
                        name = 'lazydev',
                        -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
                        group_index = 0,
                    },
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'path' },
                    { name = 'jupynium' },
                },
            }
        end,
    },
}
