local vim = vim
local g = vim.g

g["neoformat_enabled_python"] = {"black", "isort"}
g["neoformat_enabled_go"] = {"gofumpt", "goimports"}
g["neoformat_enabled_ruby"] = {"rubocop"}
g["neoformat_enabled_shell"] = {"shfmt"}
g["neoformat_enabled_lua"] = {"luaformatter"}
g["neoformat_run_all_formatters"] = 1
