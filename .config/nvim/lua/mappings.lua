local vim = vim
local api = vim.api
local fn = vim.fn

local M = {}
-- map helper
function M.map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- mappings
---- save and exit
M.map('', '<C-s>', '<esc>:w<CR>')
M.map('i', '<C-s>', '<esc>:w<CR>')

---- escape from insert mode
M.map('i', 'jk', '<esc>')
M.map('i', 'kj', '<esc>')

---- no arrow keys
M.map('', '<up>', '<nop>', {noremap = true})
M.map('', '<down>', '<nop>', {noremap = true})
M.map('', '<left>', '<nop>', {noremap=true})
M.map('', '<right>', '<nop>', {noremap=true})

M.map('i', '<up>', '<nop>', {noremap=true})
M.map('i', '<down>', '<nop>', {noremap=true})
M.map('i', '<left>', '<nop>', {noremap=true})
M.map('i', '<right>', '<nop>', {noremap=true})

---- toggle between files
M.map('n', '<leader>bb', '<c-^><cr>')

-- vim-test mappings
M.map('n', 't<C-n>', '<cmd>TestNearest<CR>', {silent=true})
M.map('n', 't<C-f>', '<cmd>TestFile<CR>', {silent=true})
M.map('n', 't<C-s>', '<cmd>TestSuite<CR>', {silent=true})
M.map('n', 't<C-l>', '<cmd>TestLast<CR>', {silent=true})
M.map('n', 't<C-g>', '<cmd>TestVisit<CR>', {silent=true})

M.map('n', 'g<C-r>', "<cmd>lua require('utils').RunScript()<CR>", {silent=true, noremap=true})


-- fzf file fuzzy search that respects .gitignore
-- If in git directory, show only files that are committed, staged, or unstaged
-- else use regular :Files
M.map('n', '<C-p>', '(len(system(\'git rev-parse\')) ? \':Files\' : \':GFiles --exclude-standard --others --cached\')."<cr>"', {noremap = true, expr = true})
M.map('n', '<leader>b', '(\':Buffers\')."<cr>"', {noremap=true, expr = true})

return M
