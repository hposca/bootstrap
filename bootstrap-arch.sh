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

  echo -e "\n[${timestamp}] ${color}${message}${nocolor}\n"
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

function install_terminal_tools() {
  log_info "Installing ZSH"

  yay -Syu --noconfirm \
    zsh

  log_info "Installing oh-my-zsh ..."
  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh

  log_info "Installing zsh plugins..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

  log_info "Installing spaceship zsh theme"
  _zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  # Gotta validate if this actually works at the first time the script is being executed
  git clone https://github.com/denysdovhan/spaceship-prompt.git "${_zsh_custom}/themes/spaceship-prompt"
  ln -s "${_zsh_custom}/themes/spaceship-prompt/spaceship.zsh-theme" "${_zsh_custom}/themes/spaceship.zsh-theme"

  log_info "Setting ZSH as the default shell"

  chsh -s "$(command -v zsh)"
}

function main {
  SECONDS=0
  packages_before=$(yay -Q | wc -l)

  log_info 'Beginning installation process ...'

  install_terminal_tools

  packages_after=$(yay -Q | wc -l)
  local -r duration=${SECONDS}

  log_info "Total number of packages before process: ${packages_before}"
  log_info "Total number of packages after process : ${packages_after}"
  log_info "The entire installation process took $((duration / 60)) minutes and $((duration % 60)) seconds."

  # display_apps_infos

  log_warn "NOTE: It's recommended that you reboot your computer now."
}

main "${@}"
