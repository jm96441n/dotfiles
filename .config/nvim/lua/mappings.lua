local vim = vim
local api = vim.api

local M = {}
-- map helper
function M.map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	api.nvim_set_keymap(mode, lhs, rhs, options)
end

local virtual_lines_enabled = true
local function toggleVirtualLines()
	virtual_lines_enabled = not virtual_lines_enabled
	vim.diagnostic.config({
		virtual_lines = virtual_lines_enabled,
		virtual_text = not virtual_lines_enabled,
	})
end

-- mappings
---- save and exit
M.map("", "<C-s>", "<esc>:w<CR>")
M.map("i", "<C-s>", "<esc>:w<CR>")

---- escape from insert mode
M.map("i", "jk", "<esc>")
M.map("i", "kj", "<esc>")

---- no arrow keys
M.map("", "<up>", "<nop>", { noremap = true })
M.map("", "<down>", "<nop>", { noremap = true })
M.map("", "<left>", "<nop>", { noremap = true })
M.map("", "<right>", "<nop>", { noremap = true })

M.map("i", "<up>", "<nop>", { noremap = true })
M.map("i", "<down>", "<nop>", { noremap = true })
M.map("i", "<left>", "<nop>", { noremap = true })
M.map("i", "<right>", "<nop>", { noremap = true })

---- toggle between files
M.map("n", "<leader>bb", "<c-^><cr>")

--- Call :Ag on the word under the cursor
M.map("n", "<leader>a", '<cmd>lua require("utils").AgSearch()<CR>', { noremap = true })

-- vim-test mappings
M.map("n", "t<C-n>", "<cmd>TestNearest<CR>", { silent = true })
M.map("n", "t<C-f>", "<cmd>TestFile<CR>", { silent = true })
M.map("n", "t<C-s>", "<cmd>TestSuite<CR>", { silent = true })
M.map("n", "t<C-l>", "<cmd>TestLast<CR>", { silent = true })
M.map("n", "t<C-g>", "<cmd>TestVisit<CR>", { silent = true })

M.map("n", "g<C-r>", "<cmd>lua require('utils').RunScript()<CR>", { silent = true, noremap = true })

-- fzf file fuzzy search that respects .gitignore
-- If in git directory, show only files that are committed, staged, or unstaged
-- else use regular :Files
M.map(
	"n",
	"<C-p>",
	"(len(system('git rev-parse')) ? ':Files' : ':GFiles --exclude-standard --others --cached').\"<cr>\"",
	{ noremap = true, expr = true }
)
M.map("n", "<leader>b", "(':Buffers').\"<cr>\"", { noremap = true, expr = true })

-- move back and forth between projections
M.map("n", "<leader>aa", ":A<CR>", { silent = true })
M.map("n", "<leader>av", ":AV<CR>", { silent = true })

-- toggle virtual lines
M.map("n", "<leader>lt", "", { callback = toggleVirtualLines })

--tmux sessionizer
M.map("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

local opts = { noremap = true, silent = true }
---- lsp
M.map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
M.map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
M.map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
M.map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
M.map("n", "gK", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
M.map("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
M.map("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
M.map("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
M.map("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
M.map("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
M.map("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
M.map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
M.map("n", "<space>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
M.map("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
M.map("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
M.map("n", "<space>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)
M.map("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

return M
