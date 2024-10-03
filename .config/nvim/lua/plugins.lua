local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(
    {
    "tanvirtin/monokai.nvim",
    "xiyaowong/transparent.nvim",
    'nvim-lualine/lualine.nvim',
    {'akinsho/bufferline.nvim', version = "*"},
    'numToStr/Comment.nvim',
    {
        "sontungexpt/stcursorword",
        event = "VeryLazy",
        config = true,
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
            -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
        }
    },
    {
        "kelly-lin/ranger.nvim",
        config = function()
            require("ranger-nvim").setup({ replace_netrw = true })
            vim.api.nvim_set_keymap("n", "<leader>ef", "", {
                noremap = true,
                callback = function()
                    require("ranger-nvim").open(true)
                end,
            })
         end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function ()
            local configs = require("nvim-treesitter.configs")
            configs.setup({
                ensure_installed = { "markdown", "markdown_inline", "html", "hyprlang" },
                sync_install = false,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },
    {
       "OXY2DEV/markview.nvim",
        lazy = false,      -- Recommended
        dependencies = {
            -- You will not need this if you installed the
            -- parsers manually
            -- Or if the parsers are in your $RUNTIMEPATH
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons"
        }
    },
    {
        "tadmccorkle/markdown.nvim",
        ft = "markdown", -- or 'event = "VeryLazy"'
        opts = {
            -- configuration here or empty for defaults
        },
    },
	-- Vscode-like pictograms
	{
		"onsails/lspkind.nvim",
		event = { "VimEnter" },
	},
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true
        -- use opts = {} for passing setup options
        -- this is equalent to setup({}) function
    },
	-- Auto-completion engine
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"lspkind.nvim",
			"hrsh7th/cmp-nvim-lsp", -- lsp auto-completion
			"hrsh7th/cmp-buffer", -- buffer auto-completion
			"hrsh7th/cmp-path", -- path auto-completion
			"hrsh7th/cmp-cmdline", -- cmdline auto-completion
		},
		config = function()
			require("config.nvim-cmp")
		end,
	},
	-- Code snippet engine
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
	},
	-- Real Neovim Copilot
    {
      "yetone/avante.nvim",
      event = "VeryLazy",
      lazy = false,
      version = false, -- set this if you want to always pull the latest change
      opts = {
        provider = "zhipu",
        vendors = {
          ---@type AvanteProvider
          zhipu = {
            endpoint = "https://open.bigmodel.cn/api/paas/v4/chat/completions",
            model = "glm-4-0520",
            api_key_name = "ZHIPU_API_KEY",
            parse_curl_args = function(opts, code_opts)
              return {
                url = opts.endpoint,
                headers = {
                  ["Accept"] = "application/json",
                  ["Content-Type"] = "application/json",
                  ["Authorization"] = "Bearer " .. os.getenv(opts.api_key_name),
                },
                body = {
                  model = opts.model,
                  messages = { -- you can make your own message, but this is very advanced
                    { role = "system", content = code_opts.system_prompt },
                    { role = "user", content = require("avante.providers.openai").get_user_message(code_opts) },
                  },
                  temperature = 0,
                  max_tokens = 4096,
                  stream = true, -- this will be set by default.
                },
              }
            end,
            parse_response_data = function(data_stream, event_state, opts)
              require("avante.providers").openai.parse_response(data_stream, event_state, opts)
            end,
          },
        }
      },
      -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
      build = "make",
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        --- The below dependencies are optional,
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
          'MeanderingProgrammer/render-markdown.nvim',
          opts = {
            file_types = { "Avante" },
          },
          ft = { "Avante" },
        },
      },
    },
	-- LSP manager
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",
	"neovim/nvim-lspconfig",
})

require('lualine').setup {
    options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}
require("bufferline").setup()
require('Comment').setup()
-- default configuration
require("stcursorword").setup({
    max_word_length = 100, -- if cursorword length > max_word_length then not highlight
    min_word_length = 2, -- if cursorword length < min_word_length then not highlight
    excluded = {
        filetypes = {
            "TelescopePrompt",
        },
        buftypes = {
            -- "nofile",
            -- "terminal",
        },
        patterns = { -- the pattern to match with the file path
            -- "%.png$",
            -- "%.jpg$",
            -- "%.jpeg$",
            -- "%.pdf$",
            -- "%.zip$",
            -- "%.tar$",
            -- "%.tar%.gz$",
            -- "%.tar%.xz$",
            -- "%.tar%.bz2$",
            -- "%.rar$",
            -- "%.7z$",
            -- "%.mp3$",
            -- "%.mp4$",
        },
    },
    highlight = {
        underline = true,
        fg = nil,
        bg = nil,
    },
})
