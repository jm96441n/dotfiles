-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.cmd([[ set nofoldenable]])

vim.filetype.add({
  extension = {
    gotmpl = "gotmpl",
    gohtml = "gotmpl",
  },
  pattern = {
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/.*%.ya?ml"] = "helm",
    ["helmfile.*%.ya?ml"] = "helm",
  },
})

-- Create a Lua function to resize windows by percentage
vim.cmd([[
lua << EOF
EOF
]])

-- Then create a command that uses this function
vim.api.nvim_create_user_command("VResizePercent", function(opts)
  local columns = vim.o.columns
  local percent = opts.fargs[1]
  local new_width = math.floor(columns * percent / 100)
  vim.cmd("vertical resize " .. new_width)
end, { nargs = 1 })
