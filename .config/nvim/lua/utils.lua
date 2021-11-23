local vim = vim
local opt = vim.opt
local api = vim.api
local fn = vim.fn

local M = {}

-- https://neovim.discourse.group/t/reload-init-lua-and-all-require-d-scripts/971/11
function M.reloadConfig()
    local hls_status = vim.v.hlsearch
    for name,_ in pairs(package.loaded) do
        if name:match('^cnull') then
            package.loaded[name] = nil
        end
    end
    dofile(vim.env.MYVIMRC)
    if hls_status == 0 then
        opt.hlsearch = false
    end
end

function M.GoImports(timeout_ms)
    local context = { only = { "source.organizeImports" } }
    vim.validate { context = { context, "t", true } }

    local params = vim.lsp.util.make_range_params()
    params.context = context

    -- See the implementation of the textDocument/codeAction callback
    -- (lua/vim/lsp/handler.lua) for how to do this properly.
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeout_ms)
    if not result or next(result) == nil then return end
    local actions = result[1].result
    if not actions then return end
    local action = actions[1]

    -- textDocument/codeAction can return either Command[] or CodeAction[]. If it
    -- is a CodeAction, it can have either an edit, a command or both. Edits
    -- should be executed first.
    if action.edit or type(action.command) == "table" then
        if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit)
    end
    if type(action.command) == "table" then
        vim.lsp.buf.execute_command(action.command)
    end
    else
        vim.lsp.buf.execute_command(action)
    end
end

local function GetFileExtension(filename)
  return filename:match("[^.]+$")
end

function M.RunScript()
    local height = 20
    local width = 75

    local ui = vim.api.nvim_list_uis()[1]
    local opts = {
        relative = 'cursor',
        width = width,
        height = height,
        col = (ui["width"] / 2) - (width / 2),
        row = (ui["height"] / 2) - (height / 2),
        anchor = 'NW',
        style = 'minimal'
    }
    local file = fn.expand("%")
    local buf = api.nvim_create_buf(false, true)
    api.nvim_open_win(buf, 1, opts)
    local filetype = GetFileExtension(file)
    local cmd = ""
    if filetype == "go" then
        cmd = "go run " .. file
    elseif filetype == "py" then
        cmd  = "python " .. file
    elseif filetype == "rb" then
        cmd  = "ruby " .. file
    end
    fn["termopen"](cmd)

end

-- taken from https://github.com/voyeg3r/nvim/blob/master/lua/utils.lua
-- used to trim trailing whitespace
function M.preserve(arguments)
    local args = string.format('keepjumps keeppatterns execute %q', arguments)
    -- local original_cursor = vim.fn.winsaveview()
    local line, col = table.unpack(api.nvim_win_get_cursor(0))
    vim.api.nvim_command(args)
	local lastline = vim.fn.line('$')
    -- vim.fn.winrestview(original_cursor)
	if line > lastline then
		line = lastline
	end
	api.nvim_win_set_cursor({0}, {line , col})
end

return M
