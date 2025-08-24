-- like this: 16:55
vim.api.nvim_create_user_command('InsertTime', function()
    vim.cmd.normal '^' -- go to beginning of line
    -- Insert before the cursor position
    vim.api.nvim_put({ string(os.date '%H:%M') }, '', false, true)
end, { desc = 'create time like 16:56' })

vim.api.nvim_create_user_command('GetLspConfig', function(opts)
    local server_name = opts.fargs[1]
    if not server_name then
        vim.notify('Error: LSP server name not provided.', vim.log.levels.ERROR)
        return
    end

    local lspconfig = require 'lspconfig'
    local server_config = lspconfig[server_name]

    if not server_config then
        vim.notify('LSP server config not found: ' .. server_name, vim.log.levels.ERROR)
        return
    end

    -- Deep copy the table to avoid modifying the original lspconfig table in memory.
    local deepcopy
    deepcopy = function(original)
        if type(original) ~= 'table' then
            return original
        end
        local copy = {}
        for k, v in pairs(original) do
            copy[deepcopy(k)] = deepcopy(v)
        end
        return copy
    end
    local config_copy = deepcopy(server_config)

    -- This helper function traverses a table and replaces function objects
    -- with a descriptive string using the debug library.
    local function describe_functions(tbl, seen)
        seen = seen or {}
        if type(tbl) ~= 'table' or seen[tbl] then
            return
        end
        seen[tbl] = true

        for k, v in pairs(tbl) do
            if type(v) == 'function' then
                local info = debug.getinfo(v, 'S')
                if info and info.source and info.linedefined > 0 then
                    local source_path = info.source:gsub('^@', '')
                    -- We create a special string that we can find and unquote later.
                    tbl[k] = string.format('---FUNC---function() --[[ defined in %s:%d ]] end---ENDFUNC---', source_path, info.linedefined)
                else
                    tbl[k] = '---FUNC---function() --[[ C function or unknown source ]] end---ENDFUNC---'
                end
            elseif type(v) == 'table' then
                describe_functions(v, seen) -- Recurse into sub-tables
            end
        end
    end

    describe_functions(config_copy)

    -- Format the modified table into a readable string using vim.inspect.
    local config_str = 'return ' .. vim.inspect(config_copy)

    -- Post-process the string to remove quotes and markers around our function descriptions,
    -- making the output appear as valid Lua code.
    config_str = config_str:gsub('"---FUNC---(.-)---ENDFUNC---"', '%1')

    -- Open a new scratch buffer to display the config.
    vim.cmd 'vnew'
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(config_str, '\n'))

    -- Set buffer options for a clean, temporary view.
    vim.bo.bufhidden = 'wipe'
    vim.bo.buftype = 'nofile'
    vim.bo.swapfile = false
    vim.bo.filetype = 'lua'
end, {
    nargs = 1,
    desc = 'Get lspconfig settings for a server, with function descriptions.',
    complete = function()
        -- Provide completion for all available servers in lspconfig.
        local lspconfig = require 'lspconfig'
        local servers = {}
        for server, _ in pairs(lspconfig) do
            if type(lspconfig[server]) == 'table' and server:sub(1, 1) ~= '_' and lspconfig[server].cmd then
                table.insert(servers, server)
            end
        end
        table.sort(servers)
        return servers
    end,
})
