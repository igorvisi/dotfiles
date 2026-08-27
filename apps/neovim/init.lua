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

vim.opt.clipboard = "unnamedplus"

-- Clipboard: OSC 52 copy without blocking paste.
-- Original forced OSC 52 paste did vim.wait(1000)+vim.wait(9000) waiting for
-- TermResponse. That freezes nvim for up to 10s when the terminal/herdr
-- --remote chain doesn't answer (common over SSH/herdr). Copy via OSC 52 is
-- still needed (herdr forwards \027]52; to the outer terminal), but paste must
-- not wait. Strategy:
--   copy: OSC 52 (always works through herdr to outer terminal)
--   paste: try native tools first (wl-paste/xclip/pbpaste, instant locally),
--          then OSC 52 query with 100ms timeout only, then return empty.
--          No 10s block; fallback to terminal paste (Ctrl-Shift-V) always works.
local function osc52_copy(reg)
	return require("vim.ui.clipboard.osc52").copy(reg)
end

local function fast_paste(reg)
	return function()
		-- 1) Native tools when available (local Wayland/X11/macOS): no OSC 52 wait.
		if vim.env.WAYLAND_DISPLAY and vim.fn.executable("wl-paste") == 1 then
			local out = vim.fn.systemlist("wl-paste --no-newline 2>/dev/null")
			if vim.v.shell_error == 0 then
				return out
			end
		end
		if vim.env.DISPLAY then
			if vim.fn.executable("xclip") == 1 then
				local out = vim.fn.systemlist("xclip -o -selection clipboard 2>/dev/null")
				if vim.v.shell_error == 0 then
					return out
				end
			end
			if vim.fn.executable("xsel") == 1 then
				local out = vim.fn.systemlist("xsel -o -b 2>/dev/null")
				if vim.v.shell_error == 0 then
					return out
				end
			end
		end
		if vim.fn.executable("pbpaste") == 1 then
			local out = vim.fn.systemlist("pbpaste 2>/dev/null")
			if vim.v.shell_error == 0 then
				return out
			end
		end

		-- 2) Fallback OSC 52 query with short timeout (100ms vs 10s default).
		-- Herdr local answers quickly; herdr --remote/SSH often doesn't - don't block.
		local contents = nil
		local id = vim.api.nvim_create_autocmd("TermResponse", {
			callback = function(ev)
				local seq = ev.data.sequence --[[@type string]]
				local encoded = seq:match("\027%]52;%w?;([A-Za-z0-9+/=]*)")
				if encoded ~= nil then
					contents = vim.base64.decode(encoded)
					return true
				end
			end,
		})
		local clip = reg == "+" and "c" or "p"
		vim.api.nvim_ui_send(string.format("\027]52;%s;?\027\\", clip))
		vim.wait(100, function()
			return contents ~= nil
		end)
		pcall(vim.api.nvim_del_autocmd, id)
		if contents ~= nil then
			return vim.split(contents, "\n")
		end
		-- 3) No response fast: don't wait 10s, return empty. Terminal paste still works.
		return { "" }
	end
end

vim.g.clipboard = {
	name = "OSC 52 (copy, fast paste - no 10s wait)",
	copy = {
		["+"] = osc52_copy("+"),
		["*"] = osc52_copy("*"),
	},
	paste = {
		["+"] = fast_paste("+"),
		["*"] = fast_paste("*"),
	},
	cache_enabled = 0,
}

-- The leader must be set before lazy.nvim so mappings resolve correctly.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Configure and install plugins ]]
require("lazy").setup({
	spec = {
		{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
		{ import = "lazyvim.plugins.extras.lang.python" },
		{ import = "lazyvim.plugins.extras.lang.typescript" },
		{ import = "lazyvim.plugins.extras.lang.go" },
		{ import = "lazyvim.plugins.extras.lang.rust" },
		-- your plugins/overrides (lazy.nvim never writes here)
		-- snacks explorer sidebar width (default: 40)
		{
			"folke/snacks.nvim",
			opts = {
				picker = { sources = { explorer = { layout = { preset = "sidebar", layout = { width = 20 } } } } },
			},
		},
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
