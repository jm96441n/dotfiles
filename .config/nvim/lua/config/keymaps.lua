-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local M = {}

local picker = require("jj.picker")
-- map helper
function M.map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- mappings
---- save and exit
M.map("", "<C-s>", "<esc>:w<CR>")
M.map("i", "<C-s>", "<esc>:w<CR>")

---- escape from insert mode
M.map("i", "jk", "<esc>")
M.map("i", "kj", "<esc>")

---- no arrow keys
M.map("", "<up>", "<nop>", { noremap = true })
M.map("", "<down>", "<nop>", { noremap = true })
M.map("", "<left>", "<nop>", { noremap = true })
M.map("", "<right>", "<nop>", { noremap = true })

M.map("i", "<up>", "<nop>", { noremap = true })
M.map("i", "<down>", "<nop>", { noremap = true })
M.map("i", "<left>", "<nop>", { noremap = true })
M.map("i", "<right>", "<nop>", { noremap = true })

-- move back and forth between projections
M.map("n", "<leader>aA", ":A<CR>", { silent = true })
M.map("n", "<leader>av", ":AV<CR>", { silent = true })

--tmux sessionizer
M.map("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- toggle term
M.map("t", "<esc>", [[<C-\><C-n>]], { noremap = true })
M.map("t", "jk", [[<C-\><C-n>]], { noremap = true })
M.map("t", "<C-h>", [[<C-\><C-n><C-W>h]], { noremap = true })
M.map("t", "<C-j>", [[<C-\><C-n><C-W>j]], { noremap = true })
M.map("t", "<C-k>", [[<C-\><C-n><C-W>k]], { noremap = true })
M.map("t", "<C-l>", [[<C-\><C-n><C-W>l]], { noremap = true })

-- JJ.nvim pickers and commands
vim.keymap.set("n", "<leader>gj", function()
  picker.status()
end, { desc = "JJ Status" })

vim.keymap.set("n", "<leader>jl", function()
  picker.log()
end, { desc = "JJ Log" })

vim.keymap.set("n", "<leader>jh", function()
  picker.file_history()
end, { desc = "JJ File History" })

-- JJ diff commands (uses codediff backend)
M.map("n", "<leader>jD", ":Jdiff<CR>", { desc = "JJ Diff (uses codediff)", silent = true })
M.map("n", "<leader>jv", ":Jvdiff<CR>", { desc = "JJ Diff (vertical)", silent = true })
M.map("n", "<leader>jH", ":Jhdiff<CR>", { desc = "JJ Diff (horizontal)", silent = true })

-- Direct CodeDiff commands
M.map("n", "<leader>cd", ":CodeDiff<CR>", { desc = "CodeDiff Explorer", silent = true })
M.map("n", "<leader>ch", ":CodeDiff history<CR>", { desc = "CodeDiff History", silent = true })

-- Hunk.nvim for selective diff editing
M.map("n", "<leader>jd", ":DiffEditor<CR>", { desc = "JJ Interactive Diff Editor (hunk)", silent = true })

-- avante
M.map("n", "<leader>am", ":AvanteChat<CR>", { silent = true })

-- harpoon keyamps
local harpoon = require("harpoon")
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
  local file_paths = {}
  for _, item in ipairs(harpoon_files.items) do
    table.insert(file_paths, item.value)
  end

  require("telescope.pickers")
    .new({}, {
      prompt_title = "Harpoon",
      finder = require("telescope.finders").new_table({
        results = file_paths,
      }),
      previewer = conf.file_previewer({}),
      sorter = conf.generic_sorter({}),
    })
    :find()
end

M.map("n", "<C-e>", function()
  toggle_telescope(harpoon:list())
end, { desc = "Open harpoon window" })

M.map("n", "<leader>ha", function()
  harpoon:list():add()
end, { desc = "Mark file" })

-- Diffview for JJ conflicts and diffs
M.map("n", "<leader>dv", ":DiffviewOpen<CR>", { desc = "Open Diffview", silent = true })
M.map("n", "<leader>dc", ":DiffviewClose<CR>", { desc = "Close Diffview", silent = true })
M.map("n", "<leader>dh", ":DiffviewFileHistory<CR>", { desc = "File History", silent = true })
M.map("n", "<leader>df", ":DiffviewFileHistory %<CR>", { desc = "Current File History", silent = true })

-- Note: Diff mode keymaps are set up automatically in autocmds.lua
-- This includes ]c/[c for navigation and <leader>co/<leader>ct for resolution
-- These work for both 2-way (jj-diffconflicts) and 3-way (vimdiff) diffs
