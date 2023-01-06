#!/usr/bin/env bash

# TODO: Install https://github.com/Mayccoll/Gogh.git and configure to use arthur
# TODO: Install cheat.sh https://github.com/chubin/cheat.sh
# TODO: Install cargo, Rust's package manager
# TODO: apt-get install -y fonts-font-awesome

# ------
# Colors
# ------
# NOCOLOR='\033[0m'
# RED='\033[0;31m'
# GREEN='\033[0;32m'
# ORANGE='\033[0;33m'
# BLUE='\033[0;34m'
# PURPLE='\033[0;35m'
# CYAN='\033[0;36m'
# LIGHTGRAY='\033[0;37m'
# DARKGRAY='\033[1;30m'
# LIGHTRED='\033[1;31m'
# LIGHTGREEN='\033[1;32m'
# YELLOW='\033[1;33m'
# LIGHTBLUE='\033[1;34m'
# LIGHTPURPLE='\033[1;35m'
# LIGHTCYAN='\033[1;36m'
# WHITE='\033[1;37m'

function log {
  local -r color="${1}"
  local -r message="${2}"
  local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  local -r nocolor='\033[0m'

  echo -e "[${timestamp}] ${color}${message}${nocolor}"
}

function log_info {
  local -r message="${1}"
  local -r green='\033[0;32m'

  log "${green}" "${message}"
}

function log_warn {
  local -r message="${1}"
  local -r green='\033[0;32m'
  local -r yellow='\033[1;33m'

  log "${yellow}" "${message}"
}

function display_apps_infos() {
  log_info "Important apps versions"

  echo "AWS CLI version: $(aws --version)"
  echo "Go version: $(go version)"
  echo "JQ version: $(jq --version)"
  echo "NPM version: $(npm --version)"
  echo "NeoVim version: $(nvim --version | grep ^NVIM)"
  echo "Node version: $(node --version)"
  echo "NodeJS version: $(nodejs --version)"
  echo "Python version: $(python3 --version)"
  echo "Ruby version: $(ruby --version)"
  echo "Yarn version: $(yarn --version)"
}

function install_base() {
  log_info "Installing base packages..."

  yay -Syu --noconfirm \
    git \
    python-pip

  log_info "Installing base packages - DONE"
}

function install_configure_gogh() {
  log_info "Installing gogh..."
  yay -Syu --noconfirm \
    python-pip

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
  log_info "Installing ZSH"

  yay -Syu --noconfirm \
    zsh

  log_info "Installing oh-my-zsh ..."
  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh

  log_info "Installing zsh plugins..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

  log_info "Installing spaceship zsh theme..."
  _zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  git clone https://github.com/denysdovhan/spaceship-prompt.git "${_zsh_custom}/themes/spaceship-prompt"
  ln -s "${_zsh_custom}/themes/spaceship-prompt/spaceship.zsh-theme" "${_zsh_custom}/themes/spaceship.zsh-theme"

  log_info "Setting ZSH as the default shell..."

  chsh -s "$(command -v zsh)"

  log_info "Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all

  log_info "Installing tmux..."
  yay -Syu --noconfirm \
    tmux

  log_info "Installing alacritty..."
  yay -Syu --noconfirm \
    alacritty
  mkdir -p "${HOME}/.config/alacritty"
  cp /usr/share/doc/alacritty/example/alacritty.yml "${HOME}/.config/alacritty"

  install_configure_gogh

  log_info "ZSH Installation - DONE"
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

function main {
  SECONDS=0
  packages_before=$(yay -Q | wc -l)

  log_info 'Beginning installation process ...'

  install_base
  install_terminal_tools

  xfce_caps_as_control

  packages_after=$(yay -Q | wc -l)
  local -r duration=${SECONDS}

  log_info "Total number of packages before process: ${packages_before}"
  log_info "Total number of packages after process : ${packages_after}"
  log_info "The entire installation process took $((duration / 60)) minutes and $((duration % 60)) seconds."

  # display_apps_infos

  log_warn "NOTE: It's recommended that you reboot your computer now."
}

main "${@}"
