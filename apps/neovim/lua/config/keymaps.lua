-- Keymaps chargées automatiquement sur l'événement VeryLazy.
-- Habitudes conservées de l'ancienne config vim, sans conflit avec LazyVim.
-- (LazyVim fournit déjà : <Esc> pour effacer les recherches, <leader>w
-- pour les fenêtres, <leader>- / <leader>| pour split/vsplit.)
local map = vim.keymap.set

-- jk pour échapper du mode insertion
map("i", "jk", "<Esc>", { desc = "Escape (jk)" })
map("v", "jk", "<Esc>", { desc = "Escape (jk)" })

-- zz sauve et quitte, zw sauve
map("n", "zz", ":x<CR>", { desc = "Save and quit" })
map("i", "zz", "<Esc>:x<CR>", { desc = "Save and quit" })
map("n", "zw", ":w<CR>", { desc = "Write" })

-- Recharge la config
map("n", "<leader>sv", ":source $MYVIMRC<CR>", { desc = "Reload config" })

-- Nouvelle ligne avant/après sans quitter le mode normal
map("n", "<leader>o", "o<ESC>", { desc = "Insert newline after" })
map("n", "<leader>O", "O<ESC>", { desc = "Insert newline before" })

-- Yank jusqu'à la fin de ligne
map("n", "Y", "y$", { desc = "Yank to end of line" })
