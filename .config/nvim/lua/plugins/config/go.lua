local vim = vim
local fn = vim.fn

local function buildTags()
	local cwd = fn.getcwd()
	if string.find(cwd, "enterprise") then
		return "consulent"
	end

	return ""
end
require("go").setup({
	luasnip = true,
	trouble = true,
	run_in_floaterm = true,
	build_tags = buildTags(),
	floaterm = { -- position
		posititon = "auto", -- one of {`top`, `bottom`, `left`, `right`, `center`, `auto`}
		width = 0.45, -- width of float window if not auto
		height = 0.98, -- height of float window if not auto
	},
})
