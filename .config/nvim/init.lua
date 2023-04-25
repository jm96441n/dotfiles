require("utils")
require("plugins")
--require("go.format").goimport()

require("plugins.config.mason")
require("plugins.config.ag")
require("plugins.config.cmp")
require("plugins.config.context")
require("plugins.config.dap")
require("plugins.config.hop")
require("plugins.config.formatter")
require("plugins.config.fugitive")
require("plugins.config.indentBlankline")
require("plugins.config.lint")
require("plugins.config.projectionist")
require("plugins.config.snips")
require("plugins.config.treesitter")
require("plugins.config.vimtest")
require("settings")
require("mappings")
require("autocmd")

require("toggleterm").setup()
require("aerial").setup()
require("go").setup({
	luasnip = true,
	trouble = true,
	run_in_floaterm = true,
	floaterm = { -- position
		posititon = "auto", -- one of {`top`, `bottom`, `left`, `right`, `center`, `auto`}
		width = 0.45, -- width of float window if not auto
		height = 0.98, -- height of float window if not auto
	},
})
