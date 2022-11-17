local luasnip = require("luasnip")

require("luasnip.loaders.from_vscode").lazy_load({
	paths = { "~/.local/share/nvim/site/pack/packer/start/friendly-snippets" },
})

require("luasnip.loaders.from_snipmate").lazy_load({
	paths = { "~/.local/share/nvim/site/pack/packer/start/LuaSnip-snippets.nvim/lua/luasnip_snippets" },
})

local ls = require("luasnip")
-- some shorthands...
local snip = ls.snippet
local text = ls.text_node
local insert = ls.insert_node

ls.add_snippets(nil, {
	python = {
		snip({
			trig = "dcl",
			namr = "New Dataclass",
			dscr = "Dataclass with documentation",
		}, {
			text({ "@dataclass", "class " }),
			insert(1, "ClassName"),
			text({ ":", '\t"""', "" }),
			insert(2, "\tDescribe the class"),
			text({ "", '\t"""', "pass" }),
		}),
	},
})
