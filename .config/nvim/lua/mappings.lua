local vim = vim
local api = vim.api
local fn = vim.fn

-- map helper
local function map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- mappings
---- save and exit
map('', '<C-s>', '<esc>:w<CR>')
map('i', '<C-s>', '<esc>:w<CR>')

---- escape from insert mode
map('i', 'jk', '<esc>')
map('i', 'kj', '<esc>')

---- no arrow keys
map('', '<up>', '<nop>', {noremap = true})
map('', '<down>', '<nop>', {noremap = true})
map('', '<left>', '<nop>', {noremap=true})
map('', '<right>', '<nop>', {noremap=true})

map('i', '<up>', '<nop>', {noremap=true})
map('i', '<down>', '<nop>', {noremap=true})
map('i', '<left>', '<nop>', {noremap=true})
map('i', '<right>', '<nop>', {noremap=true})

---- toggle between files
map('n', '<leader>bb', '<c-^><cr>')

-- vim-test mappings
map('n', 't<C-n>', '<cmd>TestNearest<CR>', {silent=true})
map('n', 't<C-f>', '<cmd>TestFile<CR>', {silent=true})
map('n', 't<C-s>', '<cmd>TestSuite<CR>', {silent=true})
map('n', 't<C-l>', '<cmd>TestLast<CR>', {silent=true})
map('n', 't<C-g>', '<cmd>TestVisit<CR>', {silent=true})

-- fzf file fuzzy search that respects .gitignore
-- If in git directory, show only files that are committed, staged, or unstaged
-- else use regular :Files
map('n', '<C-p>', '(len(system(\'git rev-parse\')) ? \':Files\' : \':GFiles --exclude-standard --others --cached\')."<cr>"', {noremap = true, expr = true})

