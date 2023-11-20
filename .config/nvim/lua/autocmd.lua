local vim = vim
local api = vim.api

local run_grp = api.nvim_create_augroup("RunCode", { clear = true })
api.nvim_create_autocmd("FileType", {
	pattern = "*.go",
	command = [[lua.require('mappings').map("n", "g<C-r>", "<cmd>lua require('utils').GoRun()<CR>", {silent=true, noremap=true})]],
	group = run_grp,
})

local format_group = api.nvim_create_augroup("FormatGroup", { clear = true })
api.nvim_create_autocmd(
	{ "BufRead", "BufNewFile" },
	{ pattern = "*.md", command = "setlocal textwidth=120", group = format_group }
)
api.nvim_create_autocmd(
	{ "BufRead", "BufNewFile" },
	{ pattern = "*.tsx", command = "setlocal shiftwidth=2 tabstop=2", group = format_group }
)

api.nvim_create_autocmd(
	{ "BufRead", "BufNewFile" },
	{ pattern = "*.jsx", command = "setlocal shiftwidth=2 tabstop=2", group = format_group }
)
api.nvim_create_autocmd("BufWritePost", { pattern = "*", command = "FormatWrite", group = format_group })

api.nvim_create_autocmd(
	{ "BufReadPost", "FileReadPost" },
	{ pattern = "*", command = "normal zR", group = format_group }
)
api.nvim_create_autocmd({ "BufReadPost", "FileReadPost", "BufWritePost" }, {
	pattern = "[^(CHANGELOG.md)]",
	callback = function()
		require("lint").try_lint()
	end,
})

-- Run gofmt + goimport on save
local format_sync_grp = vim.api.nvim_create_augroup("GoImport", {})
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	callback = function()
                --require("go.format").gofmt()
		require("go.format").goimport()
	end,
	group = format_sync_grp,
})
