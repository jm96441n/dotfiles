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
        {"BufWritePre", "$MYVIMRC/../*", "lua require('utils').reloadConfig()"};
    };
    go_run = {
      {"Filetype", "*.go", [[lua.require('mappings').map("n", "g<C-r>", "<cmd>lua require('utils').GoRun()<CR>", {silent=true, noremap=true})]]}
    };

    mkdown_file_width = {
        {"BufRead,BufNewFile", "*.md", "setlocal textwidth=120"}
    };

    format = {
        {"BufWritePost", "*", "FormatWrite"}
    };
    open_folds = {
        {"BufReadPost,FileReadPost", "*", "normal zR"}
    }
}

M.nvim_create_augroups(autoCommands)

return M
