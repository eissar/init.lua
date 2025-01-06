-- Import required modules
local fmt = require('luasnip.extras.fmt').fmt
local luasnip = require 'luasnip'
local snippet = luasnip.snippet
local snippet_node = luasnip.snippet_node
local txt = luasnip.text_node
local insert = luasnip.insert_node
-- local func = luasnip.
-- local utilEvents = require 'luasnip.util.events'
local absoluteIndexer = require 'luasnip.nodes.absolute_indexer'

--#region LUA
local a1 = snippet("function", snippet_node(0, {
  txt("local function ("),
  insert(1, "parameters"),
  txt(")"),
  txt({"", "\t"}), --newline and tab
  insert(2, "--code"),
  txt({"","end"}), --newline and end
}));

local a2 = snippet("multiline string", snippet_node(0, {
  txt("--[["),
  txt({"", ""}), --newline and tab
  insert(1, "multiline comment"),
  txt("]" .. "]" .. "--"),
  insert(2, "--code"),
  txt({"","end"}), --newline and end
}));


luasnip.add_snippets('lua', { a1,a2 })
--#endregion

-- luasnip.add_snippets('md', {
--   -- Function declaration
--   text (datef()),
-- })

