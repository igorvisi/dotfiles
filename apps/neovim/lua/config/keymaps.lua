local map = vim.keymap.set

map("i", "jk", "<Esc>", { desc = "Escape (jk)" })
map("v", "jk", "<Esc>", { desc = "Escape (jk)" })

-- zz: save and quit (kept from the pre-LazyVim config)
map("n", "zz", ":x<CR>", { desc = "Save and quit" })
map("i", "zz", "<Esc>:x<CR>", { desc = "Save and quit" })
map("n", "zw", ":w<CR>", { desc = "Write" })

map("n", "<leader>sv", ":source $MYVIMRC<CR>", { desc = "Reload config" })

map("n", "<leader>o", "o<ESC>", { desc = "Insert newline after" })
map("n", "<leader>O", "O<ESC>", { desc = "Insert newline before" })

map("n", "Y", "y$", { desc = "Yank to end of line" })
