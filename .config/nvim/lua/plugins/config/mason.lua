local vim = vim
local mason = require("mason")
local mason_lsp_config = require("mason-lspconfig")
local lspconfig = require("lspconfig")

mason.setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

require("mason-tool-installer").setup({

	-- a list of all tools you want to ensure are installed upon
	-- start; they should be the names Mason uses for each tool
	ensure_installed = {
		-- go
		"golangci-lint",
		"gopls",
		"shellcheck",
		"gofumpt",
		"golines",
		"gomodifytags",
		"gotests",
		"json-to-struct",
		"staticcheck",
		"misspell",
		"revive",
		"impl",
		"delve",
		-- bash
		"bash-language-server",
		"shellcheck",
		"shfmt",
		-- ruby
		"solargraph",
		"rubocop",
		"erb-lint",
		-- python
		"jedi-language-server",
		"flake8",
		"black",
		"isort",
		"mypy",
		-- terraform
		"tflint",
		"terraform-ls",
		-- javascript
		"eslint-lsp",
		"prettier",
		-- lua
		"lua-language-server",
		"stylua",
		-- proto
		--"buf",
		-- misc
		"editorconfig-checker",
		"codespell",
		"css-lsp",
		"gitlint",
		"json-lsp",
		"sqls",
		"vale",
	},

	-- if set to true this will check each tool for updates. If updates
	-- are available the tool will be updated. This setting does not
	-- affect :MasonToolsUpdate or :MasonToolsInstall.
	-- Default: false
	auto_update = true,

	-- automatically install / update on startup. If set to false nothing
	-- will happen on startup. You can use :MasonToolsInstall or
	-- :MasonToolsUpdate to install tools and check for updates.
	-- Default: true
	run_on_start = true,

	-- set a delay (in ms) before the installation starts. This is only
	-- effective if run_on_start is set to true.
	-- e.g.: 5000 = 5 second delay, 10000 = 10 second delay, etc...
	-- Default: 0
	start_delay = 3000, -- 3 second delay
})

mason_lsp_config.setup()

mason_lsp_config.setup_handlers({
	function(server_name)
		lspconfig[server_name].setup({})
	end,
})

require("lsp_lines").setup()
vim.diagnostic.config({
	virtual_text = false, -- removes duplication of diagnostic messages due to lsp_lines
	virtual_lines = true,
})
