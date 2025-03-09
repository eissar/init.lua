vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = false
vim.opt_local.list = false
vim.opt_local.foldmethod = 'expr'
vim.opt_local.foldexpr = 'nvim_treesitter#foldexpr()'
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

-- builtin folds.scm
-- [
--   (const_declaration)
--   (expression_switch_statement)
--   (expression_case)
--   (default_case)
--   (type_switch_statement)
--   (type_case)
--   (for_statement)
--   (func_literal)
--   (function_declaration)
--   (if_statement)
--   (import_declaration)
--   (method_declaration)
--   (type_declaration)
--   (var_declaration)
--   (composite_literal)
--   (literal_element)
--   (block)
-- ] @fold

-- what this does is offset metadata.range internally
-- of the newly captured capture_groups we put into @fold
-- this should have absolutely no collision at all with other features.

-- does not work?
-- (function_declaration
--   body: (block) @fold
--   (#offset! @fold 1 0 -1 0)

--

-- we need to write a predicate!

-- Predicate handler receive the following arguments
-- (match, pattern, bufnr, predicate)

---@param match table<integer, TSNode[]> A table mapping capture IDs to a list of captured nodes
---@param pattern integer the index of the matching pattern in the query file
---@param source integer|string
---@param predicate any[] list of strings containing the full directive being called, e.g.
---  `(node (#set! conceal "-"))` would get the predicate `{ "#set!", "conceal", "-" }`
local handler = function(match, pattern, source, predicate, metadata)
    metadata.test = 1
    print(vim.inspect(metadata))

    -- local nodes = match[predicate[2]]

    -- print(vim.inspect(metadata[pattern]))
    -- why is metadata nil?

    -- print(vim.inspect(predicate[pattern]))
    -- return: "test?"

    -- print(vim.inspect(predicate))
    -- (#test? @fold "test")
    -- return: "test?", 1, "test"
end

---@param match table<integer, TSNode[]> A table mapping capture IDs to a list of captured nodes
---@param pattern integer the index of the matching pattern in the query file
---@param source integer|string
---@param predicate any[] list of strings containing the full directive being called, e.g.
---  `(node (#set! conceal "-"))` would get the predicate `{ "#set!", "conceal", "-" }`
---@param metadata table
local inspect_nodes_handler = function(match, pattern, source, predicate, metadata)
    local nodes = match[predicate[2]]
    local txt = {}
    for _, node in ipairs(nodes) do
        local node_text = vim.treesitter.get_node_text(node, source)
        table.insert(txt, node_text)
    end
    print(vim.inspect(txt))
end

local offsettest = function(match, _, _, pred, metadata)
    local capture_id = pred[2] --[[@as integer]]
    -- local nodes = match[1] -- <userdata>
    local nodes = match[capture_id] -- <userdata>
    print(#nodes)

    if not nodes or #nodes == 0 then
        return
    end

    local txt = {}

    print(vim.inspect(txt))

    print(vim.inspect(nodes[3]))
    --assert(#nodes == 1, '#offset! does not support captures on multiple nodes')

    local node = nodes[1]

    if not metadata[capture_id] then
        metadata[capture_id] = {}
    end

    print(vim.inspect(node:range()))
    if #nodes ~= 1 then
        return
    end

    local range = metadata[capture_id].range or { node:range() }
    local start_row_offset = pred[3] or 1
    local start_col_offset = pred[4] or 0
    local end_row_offset = pred[5] or -1
    local end_col_offset = pred[6] or 0

    range[1] = range[1] + start_row_offset
    range[2] = range[2] + start_col_offset
    range[3] = range[3] + end_row_offset
    range[4] = range[4] + end_col_offset

    -- If this produces an invalid range, we just skip it.
    if range[1] < range[3] or (range[1] == range[3] and range[2] <= range[4]) then
        metadata[capture_id].range = range
    end
end

local test = function(match, _, _, pred, metadata)
    -- print(type(metadata))
    vim.notify(vim.inspect(metadata[1]))
end
vim.treesitter.query.add_directive('test!', test, { force = true })
