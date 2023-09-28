local vim = vim
-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
require("formatter").setup({
	-- Enable or disable logging
	logging = true,
	-- Set the log level
	log_level = vim.log.levels.WARN,
	-- All formatter configurations are opt-in
	filetype = {
		go = {
			require("formatter.filetypes.go").gofumpt,
			require("formatter.filetypes.go").goimports,
			function()
				return {
					exe = "goimports",
					args = { "--local github.com/hashicorp" },
					stdin = true,
				}
			end,

			function()
				return {
					exe = "gofmt",
					args = { "-s" },
					stdin = true,
				}
			end,
		},
		lua = {
			require("formatter.filetypes.lua").stylua,
		},
		python = {
			require("formatter.filetypes.python").isort,
			require("formatter.filetypes.python").black,
			function()
				return {
					exe = "black",
					args = { "-l 120", "-q", "-" },
					stdin = true,
				}
			end,
		},
		ruby = {
			require("formatter.filetypes.ruby").rubocop,
		},
		sh = {
			require("formatter.filetypes.sh").shfmt,
		},
		rust = {
			require("formatter.filetypes.rust").rustfmt,
		},
		javascript = {
			require("formatter.filetypes.javascript").prettier,
		},
		typescript = {

			require("formatter.filetypes.typescript").prettier,
		},
		-- Use the special "*" filetype for defining formatter configurations on
		-- any filetype
		["*"] = {
			-- "formatter.filetypes.any" defines default configurations for any
			-- filetype
			require("formatter.filetypes.any").remove_trailing_whitespace,
		},
	},
})
