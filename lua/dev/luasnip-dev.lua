---@meta
---@description This files is only necessary when developing snippets in lua using `LuaSnip`
---@see LuaSnip [LuaSnip's documentation](https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md)

-- if Core.has('luasnip') then
s = require('luasnip.nodes.snippet').S
sn = require('luasnip.nodes.snippet').SN
t = require('luasnip.nodes.textNode').T
f = require('luasnip.nodes.functionNode').F
i = require('luasnip.nodes.insertNode').I
c = require('luasnip.nodes.choiceNode').C
d = require('luasnip.nodes.dynamicNode').D
r = require('luasnip.nodes.restoreNode').R
snippet = require('luasnip.nodes.snippet').S
snippet_node = require('luasnip.nodes.snippet').SN
parent_indexer = require('luasnip.nodes.snippet').P
indent_snippet_node = require('luasnip.nodes.snippet').ISN
text_node = require('luasnip.nodes.textNode').T
function_node = require('luasnip.nodes.functionNode').F
insert_node = require('luasnip.nodes.insertNode').I
choice_node = require('luasnip.nodes.choiceNode').C
dynamic_node = require('luasnip.nodes.dynamicNode').D
restore_node = require('luasnip.nodes.restoreNode').R
parser = require('luasnip.util.parser')
config = require('luasnip.config')
multi_snippet = require('luasnip.nodes.multiSnippet').new_multisnippet
snippet_source = require('luasnip.session.snippet_collection.source')
cut_keys = require('luasnip.util.select').cut_keys
pre_yank = require('luasnip.util.select').pre_yank
post_yank = require('luasnip.util.select').post_yank
-- end
