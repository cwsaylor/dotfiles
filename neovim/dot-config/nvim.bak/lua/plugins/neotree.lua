return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    name = "neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      vim.keymap.set('n', '<C-n>', ':Neotree filesystem toggle left<CR>')
    end
  }
}
