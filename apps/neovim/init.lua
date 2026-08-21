-- [[ Bootstrap lazy.nvim ]]
-- La source de LazyVim et des plugins vit dans ~/.local/share/nvim/lazy,
-- gérée par git via lazy.nvim : les updates (:Lazy update / make nvim-update)
-- ne touchent jamais à ce dossier de config.
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

-- Le leader doit être défini avant lazy.nvim pour que les mappings soient corrects
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Configure and install plugins ]]
require("lazy").setup({
  spec = {
    -- import LazyVim et ses plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import des extras optionnels (à activer selon les besoins)
    -- { import = "lazyvim.plugins.extras.lang.python" },
    -- { import = "lazyvim.plugins.extras.lang.typescript" },
    -- { import = "lazyvim.plugins.extras.lang.go" },
    -- import de tes plugins / overrides (lazy.nvim n'écrit jamais ici)
    { import = "plugins" },
  },
  defaults = {
    -- lazy-load les plugins LazyVim, tes plugins seront lazy par défaut aussi
    lazy = true,
    -- toujours suivre le dernier commit git (les versions exactes sont
    -- épinglées dans lazy-lock.json, commité dans les dotfiles)
    version = false,
  },
  -- couleurs à installer avant le premier chargement (onedark)
  install = { colorscheme = { "onedark" } },
  -- détection des mises à jour : :Lazy update est volontaire et contrôlé
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
