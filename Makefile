.PHONY: install link update clean

install:
	@./script/install.sh

link:
	@./install install.yaml
	@overlay=linux; \
	if [ "$$(uname -s)" = "Darwin" ]; then overlay=macos; \
	elif grep -qi microsoft /proc/version 2>/dev/null; then overlay=wsl; \
	fi; \
	./install "install.$$overlay.yaml"

update:
	@git pull
	@make install

# Met à jour LazyVim et tous les plugins (source git gérée par lazy.nvim).
# La config dans apps/neovim n'est jamais touchée ; les versions exactes
# restent épinglées dans apps/neovim/lazy-lock.json.
nvim-update:
	@nvim --headless "+Lazy! update" +qa

clean:
	@echo "Cleaning..."
	@rm -rf ~/.tmux/plugins/tpm
	@rm -rf ~/.local/share/nvim/lazy ~/.local/share/nvim/plugged
	@echo "Done."
