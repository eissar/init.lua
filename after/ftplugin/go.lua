vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = false
vim.opt_local.list = false

vim.opt_local.foldmethod = 'expr'
vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
--vim.opt_local.foldtext = 'v:lua.parse_line'
vim.opt_local.foldtext = ''

---@return boolean
local function match_region_predicate(match, _, source, predicate)
    local start_node = match[predicate[2]] -- #region_start
    local end_node = match[predicate[3]] -- #endregion

    if not #start_node == 1 and #end_node == 1 then
        print 'ERROR'
        return false
    end

    local start_text = vim.treesitter.get_node_text(start_node[1], source)
    local end_text = vim.treesitter.get_node_text(end_node[1], source)
    if (#start_text < 11) and (#end_text < 11) then
        print 'invalid // #range tag(s)'
        return false
    end

    start_text = string.sub(start_text, 12)
    end_text = string.sub(end_text, 15)
    return (start_text ~= nil) and (start_text == end_text)
end

--fun(match: table<integer, TSNode[]>, pattern: integer, source: string|integer, predicate: any[], metadata: table)

-- Predicate handler receive the following arguments
-- (match, pattern, bufnr, predicate)

-- do like [start_nodes] (alternator) --> gets run once per start_node
-- comment
vim.treesitter.query.add_predicate('match_region?', match_region_predicate, { force = true, all = true })
-- if start_text == end_text then
--for _, node in ipairs(end_nodes) do
--    local txt = vim.treesitter.get_node_text(node, source)
--    txt = string.sub(txt, 15)
--    if start_text == txt then
--        return true
--    else
--        return false
--    end
--end

--local a = {}
--for _, node in ipairs(start_nodes) do
--    local txt = vim.treesitter.get_node_text(node, source)
--    table.insert(a, txt)

--print(vim.inspect(a))

--function M.add_predicate(name: string, handler: fun(match: table<integer, TSNode[]>, pattern: integer, source: string|integer, predicate: any[], metadata: table), opts: vim.treesitter.query.add_predicate.Opts)

-- <https://github.com/Wansmer/nvim-config/blob/main/lua/modules/foldtext.lua>
