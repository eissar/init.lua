vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = false
vim.opt_local.list = false

vim.opt_local.foldmethod = 'expr'
vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt_local.foldtext = ''

--vim.treesitter.query.add()

-- function(match, _, source, predicate)
local function match_region_predicate(match, pattern, source, predicate)
    local reg1 = match[predicate[2]]
    local reg2 = match[predicate[3]]

    print(vim.inspect { reg1, reg2 })
end

vim.treesitter.query.add_predicate('match-region?', match_region_predicate, { force = true })

-- vim.treesitter.query.add_predicate('match-region', match_region_predicate, nil)
-- -- prints <userdata>
-- (
--  [
--   (comment) @_a
--   (#lua-match? @_a "^// #region.*")
--   ] @_start
--   (#match-region? @_a @_start)
-- )
