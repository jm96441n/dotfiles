local vim = vim
local cmd = vim.cmd

cmd[[ command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, '--hidden', {'center': '~40%'}) ]]
