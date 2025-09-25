local cwd, err_name = vim.uv.cwd()
local cloud = os.getenv 'CLOUD_DIR'

local whitelist = { vim.fs.joinpath(cloud, 'Code', 'go', 'eagle-web') }
print(vim.inspect(whitelist))

if cwd == nil then
    print('could not get cwd' .. err_name)
end

-- .nvim.lua has highest precedence
-- which makes this a bit safer
local exrc_path = vim.fs.root(0, '.nvim.lua')
if exrc_path then
    require('fidget').notify 'trying'
    local choice = 0

    if vim.list_contains(whitelist, exrc_path) then
        choice = 1
    end

    if choice == 0 then
        local prompt = string.format('Local config detected. Load config at %s?', exrc_path)
        choice = vim.fn.confirm(prompt, '&Yes\n&No', 1)
    end

    if choice == 1 then
        vim.cmd('source ' .. exrc_path .. '/.nvim.lua')
    end
end
