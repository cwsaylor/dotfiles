-- =============================================================================
-- Minimal Neovim Config — Python & TypeScript
-- Drop this at: ~/.config/nvim/init.lua
-- Requires: git, node, python3, ripgrep
-- =============================================================================

-- -----------------------------------------------------------------------------
-- BOOTSTRAP lazy.nvim (plugin manager)
-- -----------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- -----------------------------------------------------------------------------
-- OPTIONS
-- -----------------------------------------------------------------------------
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.number         = true
opt.relativenumber = false
opt.expandtab      = true
opt.tabstop        = 2
opt.shiftwidth     = 2
opt.smartindent    = true
opt.wrap           = false
opt.ignorecase     = true
opt.smartcase      = true
opt.signcolumn     = "yes"
opt.updatetime     = 250
opt.timeoutlen     = 300
opt.splitright     = true
opt.splitbelow     = true
opt.scrolloff      = 8
opt.termguicolors  = true
opt.clipboard      = "unnamedplus"
opt.undofile       = true   -- persistent undo
opt.cursorline     = true

-- -----------------------------------------------------------------------------
-- KEYMAPS
-- -----------------------------------------------------------------------------
local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

-- Window navigation
map("n", "<C-h>", "<C-w>h", "Move to left window")
map("n", "<C-l>", "<C-w>l", "Move to right window")
map("n", "<C-j>", "<C-w>j", "Move to lower window")
map("n", "<C-k>", "<C-w>k", "Move to upper window")

-- Better indenting in visual mode
map("v", "<", "<gv", "Indent left")
map("v", ">", ">gv", "Indent right")

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")

-- Diagnostic navigation
map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
map("n", "<leader>e", vim.diagnostic.open_float, "Show diagnostic")

-- File explorer
map("n", "<leader>fe", "<cmd>Explore<CR>", "File explorer (netrw)")

-- -----------------------------------------------------------------------------
-- PLUGINS
-- -----------------------------------------------------------------------------
require("lazy").setup({

  -- Colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "frappe",
        term_colors = true,
        styles = {
          comments = { "italic" },
          keywords = { "italic" },
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          telescope = true,
          treesitter = true,
          which_key = true,
          fidget = true,
          mason = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { options = { theme = "catppuccin" } },
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({})
      telescope.load_extension("fzf")

      local builtin = require("telescope.builtin")
      map("n", "<leader>ff", builtin.find_files,  "Find files")
      map("n", "<leader>fg", builtin.live_grep,   "Live grep")
      map("n", "<leader>fb", builtin.buffers,     "Find buffers")
      map("n", "<leader>fh", builtin.help_tags,   "Help tags")
      map("n", "<leader>fd", builtin.diagnostics, "Diagnostics")
    end,
  },

  -- Treesitter — syntax highlighting + text objects
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter",  -- v1.0+ removed the configs submodule
    opts = {
      ensure_installed = {
        "python", "typescript", "tsx", "javascript",
        "json", "yaml", "toml", "markdown", "lua", "bash",
      },
      highlight    = { enable = true },
      indent       = { enable = true },
      auto_install = true,
    },
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSP servers
      { "williamboman/mason.nvim", config = true },
      "williamboman/mason-lspconfig.nvim",
      -- Inline LSP status messages
      { "j-hui/fidget.nvim", opts = {} },
    },
    config = function()
      -- Called when an LSP attaches to a buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local buf = event.buf
          local bmap = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
          end

          bmap("n", "gd",         vim.lsp.buf.definition,      "Go to definition")
          bmap("n", "gD",         vim.lsp.buf.declaration,     "Go to declaration")
          bmap("n", "gr",         vim.lsp.buf.references,      "References")
          bmap("n", "gi",         vim.lsp.buf.implementation,  "Implementation")
          bmap("n", "K",          vim.lsp.buf.hover,           "Hover docs")
          bmap("n", "<leader>rn", vim.lsp.buf.rename,          "Rename symbol")
          bmap("n", "<leader>ca", vim.lsp.buf.code_action,     "Code action")
          bmap("n", "<leader>ws", vim.lsp.buf.workspace_symbol,"Workspace symbols")
        end,
      })

      -- Extend LSP capabilities with nvim-cmp
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "ts_ls" },
        handlers = {
          -- Default handler — applies to all installed servers
          function(server_name)
            require("lspconfig")[server_name].setup({
              capabilities = capabilities,
            })
          end,

          -- Python — use virtual environments automatically
          ["pyright"] = function()
            require("lspconfig").pyright.setup({
              capabilities = capabilities,
              settings = {
                python = {
                  analysis = {
                    typeCheckingMode = "basic",
                    autoImportCompletions = true,
                  },
                },
              },
            })
          end,

          -- TypeScript / JavaScript
          ["ts_ls"] = function()
            require("lspconfig").ts_ls.setup({
              capabilities = capabilities,
              settings = {
                typescript = { inlayHints = { includeInlayParameterNameHints = "all" } },
                javascript = { inlayHints = { includeInlayParameterNameHints = "all" } },
              },
            })
          end,
        },
      })
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"]     = cmp.mapping.select_next_item(),
          ["<C-p>"]     = cmp.mapping.select_prev_item(),
          ["<C-d>"]     = cmp.mapping.scroll_docs(4),
          ["<C-u>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python     = { "ruff_format" },  -- pip install ruff
        typescript = { "prettier" },     -- npm i -g prettier
        javascript = { "prettier" },
        typescriptreact = { "prettier" },
        javascriptreact = { "prettier" },
        json       = { "prettier" },
        yaml       = { "prettier" },
        markdown   = { "prettier" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },

  -- Auto-close brackets / quotes
  {
    "windwp/nvim-autopairs",
    event  = "InsertEnter",
    config = true,
  },

  -- Git signs in the gutter
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local bmap = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end
        bmap("n", "]c", gs.next_hunk, "Next hunk")
        bmap("n", "[c", gs.prev_hunk, "Prev hunk")
        bmap("n", "<leader>hs", gs.stage_hunk,   "Stage hunk")
        bmap("n", "<leader>hr", gs.reset_hunk,   "Reset hunk")
        bmap("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        bmap("n", "<leader>hb", gs.blame_line,   "Blame line")
      end,
    },
  },

  -- Commenting
  {
    "numToStr/Comment.nvim",
    opts = {},
  },

  -- Surround text objects
  {
    "kylechui/nvim-surround",
    event   = "VeryLazy",
    config  = true,
  },

  -- Show pending keybinds
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts  = {},
  },

}, {
  -- lazy.nvim UI options
  ui = { border = "rounded" },
})
