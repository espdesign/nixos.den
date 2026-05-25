-- ========================================================================== --
--   NEOVIM BASIC SETTINGS
-- ========================================================================== --
vim.opt.number = true          -- Show line numbers
vim.opt.relativenumber = true  -- Show relative line numbers
vim.opt.mouse = 'a'            -- Enable mouse support
vim.opt.ignorecase = true      -- Case-insensitive searching
vim.opt.smartcase = true       -- Smart-case searching
vim.opt.tabstop = 2            -- Number of spaces tabs count for
vim.opt.shiftwidth = 2         -- Number of spaces for auto-indent
vim.opt.expandtab = true       -- Expand tabs to spaces
vim.opt.cursorline = true      -- Highlight the current line
vim.opt.termguicolors = true   -- Enable 24-bit RGB colors

-- Leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ========================================================================== --
--   MINIMAL PLUGINS VIA VIM.PACK (NEOVIM 0.12+)
-- ========================================================================== --
vim.pack.add({
  -- A robust, popular theme (Gruvbox)
  "https://github.com/ellisonleao/gruvbox.nvim",
  
  -- Treesitter for advanced, native-like syntax highlighting
  "https://github.com/nvim-treesitter/nvim-treesitter",

  -- Fuzzy finder and its dependency
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
})

-- Load & configure theme
vim.cmd("colorscheme gruvbox")

-- Enable native treesitter highlighting for all filetypes (Neovim 0.12+ style)
vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

-- Configure nvim-treesitter and install basic language parsers
local ts_ok, ts = pcall(require, 'nvim-treesitter')
if ts_ok then
  ts.setup({
    install_dir = vim.fn.stdpath('data') .. '/site'
  })
  -- Installs parsers asynchronously if not already present
  ts.install({ "nix", "lua", "javascript", "typescript", "markdown" })
end

-- Configure Telescope keybindings
local tele_ok, builtin = pcall(require, 'telescope.builtin')
if tele_ok then
  vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
  vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Search Project Text (Live Grep)' })
  vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'List Open Buffers' })
  vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Search Help Tags' })
end
