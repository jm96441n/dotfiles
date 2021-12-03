local vim = vim
local g = vim.g

g["neoformat_enabled_python_black"] = {
    exe = "black",
    args = {"-l 120"}
}

g["neoformat_enabled_python"] = {"black", "isort"}
g["neoformat_enabled_go"] = {"gofumpt", "goimports"}
g["neoformat_enabled_ruby"] = {"rubocop"}
g["neoformat_enabled_shell"] = {"shfmt"}
g["neoformat_enabled_lua"] = {"luaformatter"}
