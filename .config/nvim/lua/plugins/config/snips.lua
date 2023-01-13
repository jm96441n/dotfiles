local ls = require("luasnip")
local vim = vim

require("luasnip.loaders.from_vscode").lazy_load({
	paths = { "~/.local/share/nvim/site/pack/packer/start/friendly-snippets" },
})

require("luasnip.loaders.from_snipmate").lazy_load({
	paths = { "~/.local/share/nvim/site/pack/packer/start/LuaSnip-snippets.nvim/lua/luasnip_snippets" },
})

local unlinkgrp = vim.api.nvim_create_augroup("UnlinkSnippetOnModeChange", { clear = true })

vim.api.nvim_create_autocmd("ModeChanged", {
	group = unlinkgrp,
	pattern = { "s:n", "i:*" },
	desc = "Forget the current snippet when leaving the insert mode",
	callback = function(evt)
		if ls.session and ls.session.current_nodes[evt.buf] and not ls.session.jump_active then
			ls.unlink_current()
		end
	end,
})

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
