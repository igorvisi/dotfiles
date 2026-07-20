.PHONY: install link update clean

install:
	@./script/install.sh

link:
	@./install install.yaml
	@./install install.linux.yaml 2>/dev/null || true

update:
	@git pull
	@make install

clean:
	@echo "Cleaning..."
	@rm -rf ~/.tmux/plugins/tpm
	@rm -f ~/.local/share/nvim/site/autoload/plug.vim
	@echo "Done."
