local vim = vim
local vcmd = vim.cmd
local fn = vim.fn

local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
	vim.cmd([[packadd packer.nvim]])
end

vcmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
	-- Packer can manage itself
	use("wbthomason/packer.nvim")
	-- neovim lsp
	use("williamboman/mason.nvim")
	use("williamboman/mason-lspconfig.nvim")
	use("neovim/nvim-lspconfig")
	use("WhoIsSethDaniel/mason-tool-installer.nvim")
	use("mfussenegger/nvim-lint")

	-- DAP debugging
	use("mfussenegger/nvim-dap")
	use("leoluz/nvim-dap-go")
	use("mfussenegger/nvim-dap-python")
	use({ "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } })

	-- get some nicer UI around lsp issues
	-- use("https://git.sr.ht/~whynothugo/lsp_lines.nvim")
	use({
		"folke/trouble.nvim",
		requires = "nvim-tree/nvim-web-devicons",
		config = function()
			require("trouble").setup()
		end,
	})
	-- autocomplete with nvmp-cmp
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/nvim-cmp")
	-- luasnip
	use({
		"L3MON4D3/LuaSnip",
	})
	use("rafamadriz/friendly-snippets")
	use("molleweide/LuaSnip-snippets.nvim")
	use("saadparwaiz1/cmp_luasnip")
	-- Keybindings for navigating between vim and tmux
	use("christoomey/vim-tmux-navigator")
	-- Tabline status
	use("vim-airline/vim-airline")
	-- Themes for vim-airline
	use("vim-airline/vim-airline-themes")
	-- Colorful CSV highlighting
	use("mechatroner/rainbow_csv")
	-- FZF for fuzzy file searching
	use({
		"junegunn/fzf",
		run = function()
			vim.fn["fzf#install()"](0)
		end,
	})
	-- use '/usr/local/opt/fzf'
	use("junegunn/fzf.vim")
	-- Gruvbox theme
	use("morhetz/gruvbox")
	-- everforest theme
	use("sainnhe/everforest")
	-- Shows git diff in gutter
	use("airblade/vim-gitgutter")
	-- Markdown preview
	-- Delve Debugging
	use("sebdah/vim-delve")
	-- Grammar checking for posts
	use("rhysd/vim-grammarous")
	-- Indent highlighting
	use("Yggdroot/indentLine")

	-- Run tests from vim
	use({
		"klen/nvim-test",
		config = function()
			require("nvim-test").setup()
		end,
	})
	-- treesitter for better syntax highlighting
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
	-- neovim treesitter context
	use("nvim-treesitter/nvim-treesitter-context")
	-- formatter to format on save
	use("mhartington/formatter.nvim")
	-- show character on end of lines
	use("lukas-reineke/indent-blankline.nvim")
	-- vim-fugitive for git in vim
	use("tpope/vim-fugitive")
	use("shumphrey/fugitive-gitlab.vim")
	use("tpope/vim-rhubarb")
	-- vim-projectionist to jump between related files
	use("tpope/vim-projectionist")
	-- vim-surround to more easily quote stuff
	use("tpope/vim-surround")
	-- vim-commentary to more easily comment stuff
	use("tpope/vim-commentary")

	-- hop for better navigation
	use({
		"phaazon/hop.nvim",
		branch = "v2", -- optional but strongly recommended
	})

	-- which key to get better
	use({
		"folke/which-key.nvim",
		config = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
			require("which-key").setup()
		end,
	})

	-- toggleterm to open terminals
	use({
		"akinsho/toggleterm.nvim",
		tag = "*",
	})

	use({
		"RRethy/vim-illuminate",
		event = { "BufReadPost", "BufNewFile" },
		opts = { delay = 200 },
		config = function(_, opts)
			require("illuminate").configure(opts)

			local function map(key, dir, buffer)
				vim.keymap.set("n", key, function()
					require("illuminate")["goto_" .. dir .. "_reference"](false)
				end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
			end

			map("]]", "next")
			map("[[", "prev")

			-- also set it after loading ftplugins, since a lot overwrite [[ and ]]
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					local buffer = vim.api.nvim_get_current_buf()
					map("]]", "next", buffer)
					map("[[", "prev", buffer)
				end,
			})
		end,
		keys = {
			{ "]]", desc = "Next Reference" },
			{ "[[", desc = "Prev Reference" },
		},
	})

	use("chrisbra/Colorizer")

	use({ "ThePrimeagen/harpoon", requires = "nvim-lua/plenary.nvim" })

	use("stevearc/aerial.nvim")

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if packer_bootstrap then
		require("packer").sync()
	end

	vcmd("colorscheme everforest")
end)
