local vim = vim
local api = vim.api

local M = {}

-- autocommands
-------- This function is taken from https://github.com/norcalli/nvim_utils
function M.nvim_create_augroups(definitions)
    for group_name, definition in pairs(definitions) do
        api.nvim_command('augroup '..group_name)
        api.nvim_command('autocmd!')
        for _, def in ipairs(definition) do
            local command = table.concat(vim.tbl_flatten{'autocmd', def}, ' ')
            api.nvim_command(command)
        end
        api.nvim_command('augroup END')
    end
end



local autoCommands = {
    reload_vimrc = {
        -- Reload vim config automatically
        {"BufWritePre", "$MYVIMRC", "lua require('utils').reloadConfig()"};
    };
    --go_run = {
    --  {"Filetype", "go", "nmap", "leader<r>", "<Plug>(go-run)"}
   -- };
   -- go_tests = {
   --   {"Filetype", "go", "nmap", "leader<t>", "<Plug>(go-test)"}
   -- };
   -- go_coverage_toggle = {
   --   {"Filetype", "go", "nmap", "leader<c>", "<Plug>(go-coverage-toggle)"}
   -- };
   -- go_build = {
   --   {"Filetype", "go", "nmap", "<leader>b", [[lua require("utils").BuildGoFiles()]]}
   -- };
    go_imports = {
        {"BufWritePre", "*.go", [[lua require("utils").GoImports(1000)]]}
    };
    mkdown_file_width = {
        {"BufRead,BufNewFile", "*.md", "setlocal textwidth=120"}
    };
    clean_trailing_spaces = {
        {"BufWritePre", "*", [[lua require("utils").preserve('%s/\\s\\+$//ge')]]}
    };
}

M.nvim_create_augroups(autoCommands)

return M
