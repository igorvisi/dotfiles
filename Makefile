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

clean:
	@echo "Cleaning..."
	@rm -rf ~/.tmux/plugins/tpm
	@rm -f ~/.local/share/nvim/site/autoload/plug.vim
	@echo "Done."
