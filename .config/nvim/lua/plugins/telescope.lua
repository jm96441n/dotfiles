return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },
  keys = {
    { "<C-p>", LazyVim.pick("files", { cwd = vim.uv.cwd() }), desc = "Find Files" },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      pickers = {
        live_grep = {
          file_ignore_patterns = { "node_modules", ".git", ".venv" },
          additional_args = { "--hidden" },
        },
        find_files = {
          file_ignore_patterns = { "node_modules", ".git", ".venv" },
          hidden = true,
        },
      },
      extensions = {
        "fzf",
      },
    })
  end,
}
