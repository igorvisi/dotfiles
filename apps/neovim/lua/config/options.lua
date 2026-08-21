-- Options chargées automatiquement avant le démarrage de LazyVim.
-- Alignées sur apps/zed/settings.json : One Dark Pro, tabs 2 hard,
-- numbers relatifs, soft wrap "bounded", Maple Mono 16, curseur barre.
local opt = vim.opt

-- Zed: "tab_size": 2, "hard_tabs": true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = false

-- Zed: "relative_line_numbers": "enabled"
opt.number = true
opt.relativenumber = true

-- Zed: "soft_wrap": "bounded"
opt.wrap = true
opt.linebreak = true

-- Zed: "buffer_font_family": "Maple Mono", "buffer_font_size": 16
-- (utile pour les clients GUI de Neovim ; dans un terminal, la police
-- vient du terminal)
opt.guifont = "Maple Mono:h16"

-- Zed: "cursor_shape": "bar" -> barre verticale en mode insertion
opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr:hor20,o:block"

-- Zed: "current_line_highlight": "all"
opt.cursorline = true
