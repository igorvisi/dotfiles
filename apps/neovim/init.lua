-- [[ Bootstrap lazy.nvim ]]
-- LazyVim and plugin sources live in ~/.local/share/nvim/lazy, managed by
-- lazy.nvim; updates (:Lazy update / make nvim-update) never touch this dir.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- The leader must be set before lazy.nvim so mappings resolve correctly.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Configure and install plugins ]]
require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- { import = "lazyvim.plugins.extras.lang.python" },
    -- { import = "lazyvim.plugins.extras.lang.typescript" },
    -- { import = "lazyvim.plugins.extras.lang.go" },
    -- your plugins/overrides (lazy.nvim never writes here)
    { import = "plugins" },
  },
  defaults = {
    -- lazy-load LazyVim plugins; your plugins stay lazy by default too
    lazy = true,
    -- always track the latest git commit; exact versions are pinned in
    -- lazy-lock.json (committed in the dotfiles)
    version = false,
  },
  -- colorscheme installed before first startup to avoid the default flash
  install = { colorscheme = { "onedark" } },
  -- update check only; :Lazy update stays intentional and controlled
  checker = { enabled = true, notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
