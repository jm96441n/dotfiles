-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd({ "TermOpen" }, { command = "term://* lua set_terminal_keymaps()" })

-- Enhanced keymaps for diff mode (jj-diffconflicts, vimdiff, etc.)
vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    vim.defer_fn(function()
      if vim.wo.diff then
        local bufnr = vim.api.nvim_get_current_buf()
        local opts = { buffer = bufnr, silent = true }

        -- Helper to find other diff buffers
        local function get_other_diff_buffers()
          local current_bufnr = vim.api.nvim_get_current_buf()
          local other_bufs = {}
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if buf ~= current_bufnr and vim.wo[win].diff then
              table.insert(other_bufs, buf)
            end
          end
          return other_bufs
        end

        -- For modifiable buffers (left side in jj-diffconflicts or output in 3-way)
        if vim.bo[bufnr].modifiable then
          vim.keymap.set("n", "<leader>ct", function()
            local other_bufs = get_other_diff_buffers()
            if #other_bufs == 0 then
              vim.notify("No other diff buffer found", vim.log.levels.WARN)
            elseif #other_bufs == 1 then
              -- Simple 2-way diff - get from the other buffer
              vim.cmd("diffget " .. other_bufs[1])
              vim.cmd("diffupdate")
            else
              -- Multiple diff buffers - try to get from the first non-modifiable one
              for _, buf in ipairs(other_bufs) do
                if not vim.bo[buf].modifiable then
                  vim.cmd("diffget " .. buf)
                  vim.cmd("diffupdate")
                  return
                end
              end
              -- Fallback: just use diffget and let vim prompt
              vim.cmd("diffget")
            end
          end, vim.tbl_extend("force", opts, { desc = "Get from other (accept theirs)" }))

          vim.keymap.set("n", "<leader>co", function()
            vim.notify("Keeping current changes (ours)", vim.log.levels.INFO)
          end, vim.tbl_extend("force", opts, { desc = "Keep current (ours)" }))
        end

        -- Navigation works in any diff buffer
        vim.keymap.set("n", "]x", "]c", vim.tbl_extend("force", opts, { desc = "Next conflict" }))
        vim.keymap.set("n", "[x", "[c", vim.tbl_extend("force", opts, { desc = "Prev conflict" }))
      end
    end, 100)
  end,
})
