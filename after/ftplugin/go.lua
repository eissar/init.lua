vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = false
vim.opt_local.list = false

vim.opt_local.foldmethod = 'expr'
vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt_local.foldtext = ''

-- startrow, startcol, endrow,endcol
vim.treesitter.query.set(
    'go',
    'folds',
    [[
[
  (const_declaration)
  (expression_switch_statement)
  (expression_case)
  (default_case)
  (type_switch_statement)
  (type_case)
  (for_statement)
  (func_literal)
  (if_statement)
  (import_declaration)
  (method_declaration)
  (type_declaration)
  (var_declaration)
  (composite_literal)
  (literal_element)
  ;(comment)
  ;(block)
] @fold

( ; add offset so we can read comment text.
  (comment) @fold
  (#match? @fold "^/\\*\n")
  (#offset! @fold 1 0 -1 0)
)
( ; no offset if the comment has text on the first line
  (comment) @fold
  (#match? @fold "^/\\* [a-zA-Z]")
)


(
    (block) @fold
    (#contains? @fold "\n")
    (#offset! @fold 1 0 -1 0)
)
]]
)
