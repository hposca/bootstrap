#!/usr/bin/env bash

# TODO: Install https://github.com/Mayccoll/Gogh.git and configure to use arthur
# TODO: Install cheat.sh https://github.com/chubin/cheat.sh
# TODO: Install cargo, Rust's package manager
# TODO: apt-get install -y fonts-font-awesome

# ------
# Colors
# ------
NOCOLOR='\033[0m'
# RED='\033[0;31m'
GREEN='\033[0;32m'
# ORANGE='\033[0;33m'
# BLUE='\033[0;34m'
# PURPLE='\033[0;35m'
# CYAN='\033[0;36m'
# LIGHTGRAY='\033[0;37m'
# DARKGRAY='\033[1;30m'
# LIGHTRED='\033[1;31m'
# LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
# LIGHTBLUE='\033[1;34m'
# LIGHTPURPLE='\033[1;35m'
# LIGHTCYAN='\033[1;36m'
# WHITE='\033[1;37m'

declare -a base_packages
base_packages=(
	curl
	git
	python-pip
	ttf-font-awesome
	# ttf-nerd-fonts-symbols-2048-em
	# ttf-nerd-fonts-symbols-2048-em-mono
	ttf-roboto-mono-nerd
	wget
)

declare -a terminal_packages
terminal_packages=(
	alacritty
	bat
	git-delta
	glow
	htop
	iftop
	iotop
	ipcalc
	ncdu
	neofetch
	ranger
	screenfetch
	tig
	tmux
	tree
	w3m
	yt-dlp
	zsh
)

declare -a development_packages
development_packages=(
	aur/tfenv
	aws-cli-v2
	bottom # Usage: btm
	community/k9s
	community/kubectl
	docker
	docker-buildx
	docker-compose
	docker-scan
	fzf
	gdu
	git
	go
	jq
	lazygit
	lua
	neovim
	neovim-remote
	nodejs
	npm
	python-pynvim
	ripgrep
	ruby
	rust
	tree-sitter
	yarn
	yq
)

declare -a desktop_packages
desktop_packages=(
	aur/enpass-bin
	barrier
	digikam
	gnucash
	gnucash-docs
	steam
	vlc
	#
	chromium
	firefox
	firefox-developer-edition
	#
	gkrellm
	gparted
	#
	virtualbox
)

function log {
	local -r color="${1}"
	local -r message="${2}"
	local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")

	echo -e "[${timestamp}] ${color}${message}${NOCOLOR}"
}

function log_info {
	local -r message="${1}"

	log "${GREEN}" "${message}"
}

function log_warn {
	local -r message="${1}"

	log "${YELLOW}" "${message}"
}

function display_apps_infos() {
	log_info "Important apps versions"

	echo "AWS CLI version: $(aws --version)"
	echo "Cargo version: $(cargo version)"
	echo "Git version: $(git --version)"
	echo "Go version: $(go version)"
	echo "JQ version: $(jq --version)"
	echo "K9S version: $(k9s version)"
	echo "kubectl version: $(kubectl version)"
	echo "NeoVim version: $(nvim --version | grep ^NVIM)"
	# echo "NodeJS version: $(nodejs --version)"
	echo "Node version: $(node --version)"
	echo "NPM version: $(npm --version)"
	echo "Pip version: $(pip --version)"
	echo "Python version: $(python --version)"
	echo "Ruby version: $(ruby --version)"
	echo "Rust version: $(rustc --version)"
	echo "TFEnv version: $(tfenv --version)"
	echo "Yarn version: $(yarn --version)"
	echo "YQ version: $(yq --version)"
}

function install_packages() {
	local -r packages=("$@")

	log_info "Will install the following packages: $(
		IFS=','
		echo "${packages[*]}"
	)"

	yay -Syu --noconfirm "${packages[@]}"
}

function install_base() {
	log_info "Installing base packages..."

	install_packages "${base_packages[@]}"

	log_info "Refreshing installed fonts"
	fc-cache -fv

	log_info "Installing base packages - DONE"
}

function install_configure_gogh() {
	log_info "Installing gogh..."

	# clone the repo into "$HOME/src/gogh"
	mkdir -p "$HOME/src"
	pushd "$HOME/src" || return
	git clone https://github.com/Gogh-Co/Gogh.git gogh
	pushd gogh || return

	# necessary in the Alacritty terminal
	pip install -r requirements.txt
	export TERMINAL=alacritty

	# Enter themes dir
	pushd themes || return

	# install themes
	# For this to work, it needs to have the colors.{primary,normal,bright} keys and values uncommented
	# TODO: Make this work with some awk/sed
	./arthur.sh

	popd || return
	popd || return
	popd || return
}

function install_terminal_tools() {
	log_info "Installing terminal tools"

	install_packages "${terminal_packages[@]}"

	log_info "Installing oh-my-zsh ..."
	curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh

	log_info "Installing zsh plugins..."
	git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/
	git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

	log_info "Installing spaceship zsh theme..."
	_zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
	git clone --depth 1 https://github.com/denysdovhan/spaceship-prompt.git "${_zsh_custom}/themes/spaceship-prompt"
	ln -s "${_zsh_custom}/themes/spaceship-prompt/spaceship.zsh-theme" "${_zsh_custom}/themes/spaceship.zsh-theme"

	log_info "Setting ZSH as the default shell..."

	chsh -s "$(command -v zsh)"

	log_info "Installing fzf..."
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install --all

	log_info "Configuring alacritty..."

	mkdir -p "${HOME}/.config/alacritty"
	cp /usr/share/doc/alacritty/example/alacritty.yml "${HOME}/.config/alacritty"

	# install_configure_gogh

	log_info "Configuring ranger..."
	ranger --copy-config=rc
	sed -i 's/set preview_images false/set preview_images true/g' ~/.config/ranger/rc.conf

	log_info "Terminal Tools Installation - DONE"
}

function install_desktop_tools() {
	log_info "Installing desktop tools"

	install_packages "${desktop_packages[@]}"

	log_info "Desktop Tools Installation - DONE"
}

function xfce_caps_as_control() {
	log_info "Configuring CAPS as Control..."

	cat >"${HOME}/.config/autostart/CapsAsControl.desktop" <<EOF
[Desktop Entry]
Encoding=UTF-8
Version=0.9.4
Type=Application
Name=CapsAsControl
Comment=Caps as Control
Exec=setxkbmap -option ctrl:nocaps
OnlyShowIn=XFCE;
RunHook=0
StartupNotify=false
Terminal=false
Hidden=false
EOF

	log_info "Configuring CAPS as Control - DONE"
}

function install_development_tools() {
	log_info "Installing development tools..."

	install_packages "${development_packages[@]}"

	log_info "Will create GO directory..."
	sudo mkdir /usr/local/go/

	log_info "Installing development tools - DONE"
}

function install_lunarvim() {
	log_info "Installing Lunarvim..."

	# LV_BRANCH='release-1.2/neovim-0.8' bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) -y

	log_info "Installing Lunarvim - DONE"
}

function prepare_dotfiles() {
	local -r clone_location="${HOME}/src/hposca/dotfiles"
	mkdir -p "${clone_location}"

	log_info "Cloning LazyVim..."
	git clone --depth 1 https://github.com/LazyVim/starter "${HOME}/.config/LazyVim"

	log_info "Cloning dotfiles..."
	git clone --depth 1 https://github.com/hposca/dotfiles "${clone_location}"

	log_info "Configuring oh-my-zsh theme..."
	ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
	git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
	ln -sf "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

	log_info "Making sure directories exist..."
	mkdir -p "${HOME}/.config/alacritty/"
	mkdir -p "${HOME}/.config/LazyVim/"
	mkdir -p "${HOME}/.config/tmux/"

	log_info "Symlinking dotfiles..."
	pushd "${clone_location}" || exit
	ln -sf "$(readlink -f tmux.conf)" "${HOME}/.config/tmux/.tmux.conf"
	ln -sf "$(readlink -f zshrc)" "${HOME}/.zshrc"
	ln -sf "$(readlink -f alacritty.yml)" "${HOME}/.config/alacritty/alacritty.yml"
	mv "${HOME}/.config/LazyVim/lua" "${HOME}/.config/LazyVim/lua-backup"
	ln -sf "$(readlink -f LazyVim/lua)" "${HOME}/.config/LazyVim/"
	ln -sf "$(readlink -f snippets)" "${HOME}/.config/LazyVim/"
	popd || exit

	log_info "Updating LazyVim with new plugins..."
	NVIM_APPNAME=LazyVim nvim --headless "+Lazy! sync" +qa
}

function main {
	SECONDS=0
	packages_before=$(yay -Q | wc -l)

	log_info 'Beginning installation process ...'

	# display_apps_infos

	# install_base
	# install_terminal_tools
	# install_desktop_tools
	#
	# xfce_caps_as_control
	#
	# install_development_tools
	# install_lunarvim

	prepare_dotfiles

	packages_after=$(yay -Q | wc -l)
	local -r duration=${SECONDS}

	log_info "Total number of packages before process: ${packages_before}"
	log_info "Total number of packages after process : ${packages_after}"
	log_info "The entire installation process took $((duration / 60)) minutes and $((duration % 60)) seconds."

	# display_apps_infos

	log_warn "NOTE: It's recommended that you reboot your computer now."
}

main "${@}"
