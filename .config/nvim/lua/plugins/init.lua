local vim = vim
local cmd = vim.cmd
local call = vim.call
local fn = vim.fn

-- install vim-plug if it's not installed
local plugFile = io.open('~/.vim/autoload/plug.vim', 'w')
if plugFile~=nil then
    local http = require('socket.http')
    local body = http.request('https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
    plugFile:write(body)
    local autoCommand = { auto_install_plugs = {{"VimEnter", "*", "PlugInstall --sync | source $MYVIMRC"}}}
    require ('autocmd').nvim_create_augroups(autoCommand)
    io.close(plugFile)
end


-- Plugins
local Plug = fn['plug#']

call('plug#begin', '~/.vim/plugged')
-- neovim lsp
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'
-- autocomplete with nvmp-cmp
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
-- luasnip
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'

-- Keybindings for navigating between vim and tmux
Plug 'christoomey/vim-tmux-navigator'
-- Tabline status
Plug 'vim-airline/vim-airline'
-- Themes for vim-airline
Plug 'vim-airline/vim-airline-themes'
-- Colorful CSV highlighting
Plug 'mechatroner/rainbow_csv'
-- Useful VIM defaults
Plug 'tpope/vim-sensible'
-- Surround things
Plug 'tpope/vim-surround'
-- Useful git functionality
Plug 'tpope/vim-fugitive'
-- vim-go for some niceties around running go_tests
Plug('fatih/vim-go', { ['do'] = fn["GoUpdateBinaries"] })
-- FZF for fuzzy file searching
Plug ('junegunn/fzf', { ['do'] = fn['fzf#install'] })
-- Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
-- Gruvbox theme
Plug 'morhetz/gruvbox'
-- Easily create wrapping tags
Plug 'tpope/vim-surround'
-- Shows git diff in gutter
Plug 'airblade/vim-gitgutter'
-- Markdown preview
Plug ('iamcco/markdown-preview.nvim', { ['do'] = 'cd app & yarn install' })
-- Delve Debugging
Plug 'sebdah/vim-delve'
-- Grammar checking for posts
Plug 'rhysd/vim-grammarous'
-- Indent highlighting
Plug 'Yggdroot/indentLine'

call('plug#end')

cmd('colorscheme gruvbox')

--[[
local cmp = require'cmp'

cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end,
    },
    mapping = {
        ['<tab>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<Down>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ['<Up>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        })
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' }, -- For luasnip users.
    }, {
        { name = 'buffer' },
    })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
    sources = {
        { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

local lsp_installer = require("nvim-lsp-installer")
local cmp_lsp = require('cmp_nvim_lsp')
local lsp_installer_servers = require'nvim-lsp-installer.servers'

-- Provide settings first!
lsp_installer.settings({
    ui = {
        icons = {
            server_installed = "✓",
            server_pending = "➜",
            server_uninstalled = "✗"
        }
    }
})

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

end


local requestedLSPServers = {
    gopls = {
        cmd = {"gopls", "serve"},
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
          },
        },
    },
    solargraph = {},
    dockerls = {},
    bashls = {},
    sumneko_lua = {},
    phpactor = {},
    pyright = {},
    sqlls = {},
    tflint = {},
    jsonls = {},
    eslint = {},
    clangd = {},
    rust_analyzer = {}
}

for lsp, opts in pairs(requestedLSPServers) do
    local capabilities = cmp_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())
    local available, lsp_server = lsp_installer_servers.get_server(lsp)
    opts["on_attach"] = on_attach
    opts["capabilities"] = capabilities
    opts["flags"] = { debounce_text_changes = 150 }
    if available then
        lsp_server:install()
    end
    lsp_server:on_ready(function()
        lsp_server:setup(opts)
    end)
end

]]--
