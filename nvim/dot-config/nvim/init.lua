-- ============ Basics ============
vim.opt.wrap = false
vim.opt.number = true
vim.opt.numberwidth = 3
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

-- Leader & keymaps
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { silent = true, desc = "Write" })
vim.keymap.set("n", "<leader>q", "<cmd>quit<cr>",  { silent = true, desc = "Quit" })

-- Clipboard (macOS)
vim.opt.clipboard:append({ "unnamed", "unnamedplus" })

-- ============ Plugins (vim.pack) ============
vim.pack.add({
  { src = "https://github.com/loctvl842/monokai-pro.nvim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/braxtons12/blame_line.nvim" },
  { src = "https://github.com/ibhagwan/fzf-lua" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" }, -- optional icons
  { src = "https://github.com/github/copilot.vim" },           -- ⇦ GitHub Copilot
})

-- ============ Plugin Setup ============
-- Theme
do
  local ok, monokai = pcall(require, "monokai-pro")
  if ok then
    monokai.setup({
      filter = "ristretto",
      transparent_background = false,
      terminal_colors = true,
      styles = {
        comment = { italic = true },
        keyword = { italic = true },
        type    = { italic = true },
      },
    })
    vim.cmd.colorscheme("monokai-pro")
  else
    vim.notify("monokai-pro not available: " .. monokai, vim.log.levels.WARN)
  end
end

-- Transparent statusline (active + inactive), persist after colorscheme changes
local function set_statusline_transparent()
  vim.api.nvim_set_hl(0, "StatusLine",   { bg = "NONE" })
  vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })
end
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_statusline_transparent })
set_statusline_transparent()

-- blame_line.nvim
do
  local ok, bl = pcall(require, "blame_line")
  if ok then
    bl.setup({
      show_in_visual = true,
      show_in_insert = false,
      delay = 100,
      date = { relative = true, format = "%Y-%m-%d" },
      template = "<author> • <author-time> • <summary>",
      prefix = " ",
    })
    vim.keymap.set("n", "<leader>gb", "<cmd>BlameLineToggle<CR>",  { desc = "Git: blame line toggle" })
    -- vim.keymap.set("n", "<leader>gB", "<cmd>BlameLineEnable<CR>",  { desc = "Git: blame line ON" })
    -- vim.keymap.set("n", "<leader>gX", "<cmd>BlameLineDisable<CR>", { desc = "Git: blame line OFF" })
  else
    vim.notify("blame_line.nvim not available: " .. bl, vim.log.levels.WARN)
  end
end

-- Oil: navigator on <leader>o
do
  local ok, oil = pcall(require, "oil")
  if ok then
    oil.setup({ default_file_explorer = true })
    vim.keymap.set("n", "<leader>o", function() oil.open() end, { desc = "Oil: parent directory" })
  else
    vim.notify("oil.nvim not available: " .. oil, vim.log.levels.WARN)
  end
end

-- fzf-lua: finder on <leader>ff (rounded borders here)
do
  local ok, fzf = pcall(require, "fzf-lua")
  if ok then
    fzf.setup({
      winopts = { border = "rounded" },
    })
    vim.keymap.set("n", "<leader>ff", function() fzf.files() end, { desc = "Find files (fzf)" })
  else
    vim.notify("fzf-lua not available: " .. fzf, vim.log.levels.WARN)
  end
end

-- ============ GitHub Copilot ============
-- Requires Node.js 18+ in PATH. First-time auth: :Copilot setup
vim.g.copilot_no_tab_map = true  -- don't steal <Tab>
-- Insert-mode keymaps
vim.keymap.set("i", "<C-l>", 'copilot#Accept("<CR>")',
  { expr = true, silent = true, replace_keycodes = false, desc = "Copilot: accept" })
vim.keymap.set("i", "<C-]>", 'copilot#Next()',
  { expr = true, silent = true, desc = "Copilot: next suggestion" })
vim.keymap.set("i", "<C-\\>", 'copilot#Dismiss()',
  { expr = true, silent = true, desc = "Copilot: dismiss" })
-- Normal-mode helpers
vim.keymap.set("n", "<leader>ce", "<cmd>Copilot enable<CR>",  { desc = "Copilot: enable" })
vim.keymap.set("n", "<leader>cd", "<cmd>Copilot disable<CR>", { desc = "Copilot: disable" })
vim.keymap.set("n", "<leader>cs", "<cmd>Copilot status<CR>",  { desc = "Copilot: status" })
