local vim = vim
local opt = vim.opt
local api = vim.api
local call = vim.call

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

function M.BuildGoFiles()
  local file = api.buf_get_name(0)
  local testEnding = "_test.go"
  local goEnding = ".go"
  if file:sub(-#testEnding) == testEnding then
    call("go#cmd#Build(0)")
  elseif file:sub(-#goEnding) == goEnding then
    call("go#cmd#Build(0)")
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

-- taken from https://github.com/voyeg3r/nvim/blob/master/lua/utils.lua
-- used to trim trailing whitespace
function M.preserve(arguments)
    local arguments = string.format('keepjumps keeppatterns execute %q', arguments)
    -- local original_cursor = vim.fn.winsaveview()
    local line, col = table.unpack(api.nvim_win_get_cursor(0))
    vim.api.nvim_command(arguments)
	local lastline = vim.fn.line('$')
    -- vim.fn.winrestview(original_cursor)
	if line > lastline then
		line = lastline
	end
	vim.api.nvim_win_set_cursor({0}, {line , col})
end

return M
