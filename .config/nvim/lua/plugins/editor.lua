local vim = vim
local fn = vim.fn

local function parse_frontmatter(content)
  local frontmatter = {}

  -- Check if content starts with frontmatter
  if not content:match("^%s*%-%-%-") then
    return frontmatter
  end

  -- Extract frontmatter content between --- markers
  local fm_content = content:match("^%s*%-%-%-\n(.-)%-%-%-")
  if not fm_content then
    return frontmatter
  end

  -- Parse key-value pairs
  for line in fm_content:gmatch("([^\n]+)") do
    local key, value = line:match("^%s*([%w_%-]+)%s*:%s*(.*)$")
    if key and value then
      -- Handle different quote types and trim whitespace
      value = value:gsub("^%s+", ""):gsub("%s+$", "")

      -- Remove surrounding quotes (single or double)
      if value:match("^['\"].*['\"]$") then
        value = value:sub(2, -2)
      end

      frontmatter[key] = value
    end
  end

  return frontmatter
end

local function strip_frontmatter(content)
  -- Check if content starts with frontmatter
  if not content:match("^%s*%-%-%-") then
    return content
  end

  -- Find the end of frontmatter
  local lines = {}
  local in_frontmatter = true
  local found_start = false

  for line in content:gmatch("([^\n]*)\n?") do
    if line:match("^%-%-%-$") then
      if not found_start then
        found_start = true
      else
        -- Found closing ---, skip this line and exit frontmatter
        in_frontmatter = false
      end
    elseif not in_frontmatter then
      table.insert(lines, line)
    end
    -- Skip lines that are in frontmatter
  end

  return table.concat(lines, "\n"):gsub("^%s+", ""):gsub("%s+$", "")
end

local function is_hashi_project()
  return vim.fn.getcwd():find("hashi") ~= nil
end

local function discover_prompt_files(directory)
  directory = directory or "."
  local shortcuts = {}

  -- Use vim.fn.glob for better Neovim integration
  local files = vim.fn.glob(directory .. "/**/*.prompt.md", false, true)

  for _, filepath in ipairs(files) do
    local filename = vim.fn.fnamemodify(filepath, ":t:r"):gsub("%.prompt$", "")

    local file = io.open(filepath, "r")
    if file then
      local full_content = file:read("*all")
      file:close()

      local frontmatter = parse_frontmatter(full_content)
      local content = strip_frontmatter(full_content)

      if content and content ~= "" then
        local name = filename:match("%-([^%-]+)$") or filename

        -- Extract description from frontmatter
        local description = frontmatter.description or ("Prompt from " .. filename)

        -- You can also extract other useful fields
        local details = {}
        if frontmatter.mode then
          table.insert(details, "Mode: " .. frontmatter.mode)
        end
        if frontmatter.model then
          table.insert(details, "Model: " .. frontmatter.model)
        end

        table.insert(shortcuts, {
          name = name,
          description = description,
          details = #details > 0 and table.concat(details, " | ") or nil,
          prompt = content,
        })
      end
    else
      vim.notify("Could not read file: " .. filepath, vim.log.levels.WARN)
    end
  end

  return shortcuts
end

return {
  -- add everforest
  {
    "neanias/everforest-nvim",
    version = false,
    lazy = false,
    priority = 1000, -- make sure to load this before all the other start plugins
  },

  -- allow highlighting of helm charts
  { "towolf/vim-helm" },

  -- Configure LazyVim to load everforest
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "everforest",
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        sh = { "shfmt" },
        gohtml = { "prettier" },
        gotmpl = { "prettier" },
      },
    },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "fredrikaverpil/neotest-golang",
    },
    opts = {
      adapters = {
        ["neotest-golang"] = {
          go_test_args = function()
            local root = vim.fn.getcwd() -- or use a root detection function
            return {
              "-v",
              "-race",
              "-count=1",
              "-coverprofile=" .. root .. "/cover.out",
            }
          end,
          -- Here we can set options for neotest-golang, e.g.
          -- go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
          dap_go_enabled = true, -- requires leoluz/nvim-dap-go
        },
      },
    },
  },
  {
    "andythigpen/nvim-coverage",
    version = "*",
    config = function()
      require("coverage").setup({
        auto_reload = true,
        lang = {
          go = {
            coverage_file = vim.fn.getcwd() .. "/cover.out",
          },
        },
      })
    end,
  },
  -- easy alternate file switching
  {
    "tpope/vim-projectionist",
    config = function()
      vim.g.projectionist_heuristics = {
        ["*"] = {
          ["*_test.go"] = { alternate = "{}.go" },
          ["*.go"] = { alternate = "{}_test.go" },
        },
      }
    end,
  },
  -- configure toggleterm
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = 20,
      open_mapping = [[<C-t>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local cmp = require("cmp")

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            -- You could replace select_next_item() with confirm({ select = true }) to get VS Code autocompletion behavior
            cmp.select_next_item()
          elseif vim.snippet.active({ direction = 1 }) then
            vim.schedule(function()
              vim.snippet.jump(1)
            end)
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif vim.snippet.active({ direction = -1 }) then
            vim.schedule(function()
              vim.snippet.jump(-1)
            end)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    build = (not LazyVim.is_win())
        and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
      or nil,
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      {
        "nvim-cmp",
        dependencies = {
          "saadparwaiz1/cmp_luasnip",
        },
        opts = function(_, opts)
          opts.snippet = {
            expand = function(args)
              require("luasnip").lsp_expand(args.body)
            end,
          }
          table.insert(opts.sources, { name = "luasnip" })
        end,
      },
    },
    opts = {
      history = false,
      delete_check_events = "TextChanged",
    },
    -- stylua: ignore
    keys = {
      {
        "<tab>",
        function()
          return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
        end,
        expr = true, silent = true, mode = "i",
      },
      { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
      { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
    },
  },
  -- configure gopls lsp client
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        ast_grep = {
          cmd = { "ast-grep", "lsp" },
          filetypes = {
            "javascript",
            "typescript",
            "python",
            "rust",
            "go",
            "java",
            "cpp",
            "c",
            "html",
            "css",
            "lua",
            "jsx",
            "tsx",
          },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern("sgconfig.yml", "sgconfig.yaml", ".git")(fname)
          end,
          single_file_support = false, -- Only start in projects with sgconfig
        },
        gopls = {
          cmd = { "gopls", "-remote=auto" },
          keys = {
            -- Workaround for the lack of a DAP strategy in neotest-go: https://github.com/nvim-neotest/neotest-go/issues/12
            { "<leader>td", "<cmd>lua require('dap-go').debug_test()<CR>", desc = "Debug Nearest (Go)" },
          },
          settings = {
            gopls = {
              gofumpt = not is_hashi_project(), -- dont use gofumpt formatting in hashicorp projects
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                fieldalignment = false,
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
              semanticTokens = true,
            },
          },
        },
      },
      setup = {
        gopls = function(_, opts)
          -- workaround for gopls not supporting semanticTokensProvider
          -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
          require("lazyvim.util").lsp.on_attach(function(client, _)
            if client.name == "gopls" then
              if not client.server_capabilities.semanticTokensProvider then
                local semantic = client.config.capabilities.textDocument.semanticTokens
                client.server_capabilities.semanticTokensProvider = {
                  full = true,
                  legend = {
                    tokenTypes = semantic.tokenTypes,
                    tokenModifiers = semantic.tokenModifiers,
                  },
                  range = true,
                }
              end
            end
          end)
          -- end workaround
        end,
      },
    },
  },

  -- syntax highlighting for gotmpl
  {
    "ngalaiko/tree-sitter-go-template",
    setup = function()
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.gotmpl = {
        install_info = {
          url = "https://github.com/ngalaiko/tree-sitter-go-template",
          files = { "src/parser.c" },
        },
        filetype = "gotmpl",
        used_by = { "gohtmltmpl", "gotexttmpl", "gotmpl", "yaml" },
      }
    end,
  },

  -- markdown preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },

  -- tmux navigator
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },

  -- oil for better file management
  {
    "stevearc/oil.nvim",
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("harpoon"):setup({})
    end,
  },
  -- disable some UI stuff
  { "akinsho/bufferline.nvim", enabled = false },
  { "folke/noice.nvim", enabled = false },
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
    config = function()
      require("mcphub").setup({
        extensions = {
          avante = {
            make_slash_commands = true, -- make /slash commands from MCP server prompts
          },
        },
      })
    end,
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    opts = {
      -- add any opts here
      -- for example
      provider = "copilot",
      mode = "agentic",
      providers = {
        copilot = {
          model = "claude-sonnet-4.5", -- updated model
          proxy = nil,
          allow_insecure = false,
          timeout = 10 * 60 * 1000,
          extra_request_body = {
            temperature = 0,
            max_completion_tokens = 1000000,
          },
        },
      },
      shortcuts = discover_prompt_files("./.github/prompts"),

      system_prompt = function()
        local hub = require("mcphub").get_hub_instance()
        return hub and hub:get_active_servers_prompt() or ""
      end,
      disabled_tools = {
        "search_files", -- Important: disable this for ast-grep to be preferred
      },
      -- Using function prevents requiring mcphub before it's loaded
      custom_tools = function()
        local mcp_tools = {
          require("mcphub.extensions.avante").mcp_tool(),
        }
        -- Create ast-grep tool with func instead of command
        local ast_search_tool = {
          name = "ast_search",
          description = "Search code using AST patterns with ast-grep",
          param = {
            type = "table",
            fields = {
              {
                name = "pattern",
                description = "AST pattern to search for",
                type = "string",
                required = true,
              },
              {
                name = "language",
                description = "Programming language",
                type = "string",
                required = false,
              },
            },
          },
          returns = {
            {
              name = "result",
              description = "AST search results",
              type = "string",
            },
            {
              name = "error",
              description = "Error message if search failed",
              type = "string",
              optional = true,
            },
          },
          func = function(params)
            vim.notify("Running AST search for pattern: " .. params.pattern, vim.log.levels.INFO)
            local args = { "ast-grep", "run", "-p", params.pattern, "." }
            if params.language then
              table.insert(args, 3, "-l")
              table.insert(args, 4, params.language)
            end

            local cmd = table.concat(args, " ")
            local handle = io.popen(cmd .. " 2>&1")
            local result = handle:read("*a")
            handle:close()

            if result and result ~= "" then
              -- Simple fix: replace all newlines with spaces
              local clean_result = result:gsub("\n", " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
              return { result = clean_result }
            else
              return { result = "No matches found" }
            end
          end,
        }
        table.insert(mcp_tools, ast_search_tool)
        return mcp_tools
      end,
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
  {
    "saghen/blink.cmp",
    dependencies = {
      "Kaiser-Yang/blink-cmp-avante",
      -- ... Other dependencies
    },
    opts = {
      sources = {
        -- Add 'avante' to the list
        default = { "avante", "lsp", "path", "buffer" },
        providers = {
          avante = {
            module = "blink-cmp-avante",
            name = "Avante",
            opts = {
              -- options for blink-cmp-avante
            },
          },
        },
      },
    },
  },
  {
    "dlyongemallo/diffview.nvim",
  },
  {
    "rafikdraoui/jj-diffconflicts",
  },
  {
    "nicolasgb/jj.nvim",
    version = "*", -- Use latest stable release
    -- Or from the main branch (uncomment the branch line and comment the version line)
    -- branch = "main",
    dependencies = { "dlyongemallo/diffview.nvim" }, -- Ensure codediff loads first
    config = function()
      require("jj").setup({
        picker = {
          -- Here you can pass the options as you would for snacks.
          -- It will be used when using the picker
          snacks = {},
        },
        keymaps = {
          log = {
            checkout = "<CR>",
            describe = "d",
            diff = "<S-d>",
            abandon = "<S-a>",
            fetch = "<S-f>",
          },
          status = {
            open_file = "<CR>",
            restore_file = "<S-x>",
          },
          close = { "q", "<Esc>" },
        },
        diff = {
          backend = "codediff",
        },
      })
    end,
  },
}
