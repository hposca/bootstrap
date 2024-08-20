#!/usr/bin/env bash

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
  archlinux-keyring
  endeavouros-keyring
  curl
  git
  ttf-font-awesome
  ttf-roboto-mono-nerd
  wget
)

declare -a terminal_packages
terminal_packages=(
  alacritty
  aur/cht.sh-git
  aur/gogh-git
  bat
  fx
  git-delta
  glow
  imagemagick
  inotify-tools
  ipcalc
  lazygit
  ranger
  sshfs
  tig
  tmux
  tree
  xclip
  xxd
  yq
  yt-dlp
  zsh
  #
  neofetch
  screenfetch
  #
  cpupower
  fdupes
  gdu
  htop
  hwdetect
  iftop
  iotop
  ncdu
  #
  lynx
  w3m
  # monitoring
  aur/btop-gpu-git
  aur/ookla-speedtest-bin
  gkrellm
  glances
  gnome-system-monitor
  prometheus-node-exporter
)

declare -a development_packages
development_packages=(
  #
  aur/aws-cli-v2
  aur/lazydocker
  aur/neovim-remote
  aur/tfenv
  aws-vault
  direnv
  docker
  docker-buildx
  docker-compose
  docker-scan
  fzf
  git
  git-crypt
  git-lfs
  github-cli
  go
  golangci-lint
  graphviz
  jq
  k9s
  kubectl
  kubectx
  kustomize
  lua
  neovim
  nodejs
  npm
  ripgrep
  ruby
  rust
  tree-sitter
  tree-sitter-cli
  yarn
  yq
  # Python
  ipython
  python-black
  python-ipdb
  python-pip
  python-pipenv
  python-pipx
  python-pre-commit
  python-pylint
  python-pynvim
  # Bash
  shellcheck
  # Extras
  # aur/argocd
  # aur/google-cloud-cli
  # aur/google-cloud-cli-gke-gcloud-auth-plugin
  # aur/kind
  # aur/rancher-k3d-bin
  # helm
  # istio
)

declare -a desktop_packages
desktop_packages=(
  aur/enpass-bin
  aur/rofi-greenclip
  aur/xkblayout-state-git
  barrier
  digikam
  gnome-calculator
  gnucash
  gnucash-docs
  libreoffice-still
  libreoffice-still-br
  libreoffice-still-ca
  power-profiles-daemon
  steam
  syncthing
  vlc
  #
  rofimoji
  xdotool
  #
  # nvidia
  # nvidia-settings
  #
  aur/librewolf-bin
  aur/slack-desktop
  aur/zoom
  chromium
  firefox
  firefox-developer-edition
  #
  gparted
  #
  virtualbox
  #
  zathura
  zathura-djvu
  zathura-pdf-mupdf
  zathura-ps
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
  local -r moment="${1}"
  local -r filename="${apps-infos-}${moment}.txt"

  log_info "Important apps versions"

  {
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
  } | tee "${filename}"
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

function install_terminal_tools() {
  log_info "Installing terminal tools"

  install_packages "${terminal_packages[@]}"

  log_info "Installing oh-my-zsh ..."
  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh

  log_info "Installing zsh plugins..."
  git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/
  git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

  log_info "Setting ZSH as the default shell..."
  chsh -s "$(command -v zsh)"

  log_info "Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all

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

function install_fonts() {
  log_info "Instaling fonts..."

  yay -Sgq nerd-fonts | yay -Syu --noconfirm -

  log_info "Done Instaling fonts"
}

function install_development_tools() {
  log_info "Installing development tools..."

  install_packages "${development_packages[@]}"

  log_info "Will create GO directory..."
  sudo mkdir /usr/local/go/

  log_info "Installing development tools - DONE"
}

# Installs and configure dependencies for the dotfiles to work propertly
function prepare_dotfiles() {
  local -r clone_location="${HOME}/src/hposca/dotfiles"
  mkdir -p "${clone_location}"

  log_info "Cloning dotfiles..."
  git clone --depth 1 https://github.com/hposca/dotfiles "${clone_location}"

  # NOTE
  # It may be necessay to add a small sleep in async.zsh to avoid rendering problems:
  # In /${HOME}/.oh-my-zsh/custom/themes/spaceship-prompt/async.zsh
  #
  # diff --git a/async.zsh b/async.zsh
  # index de13e75..15740db 100644
  # --- a/async.zsh
  # +++ b/async.zsh
  # @@ -28,6 +28,8 @@ _async_job() {
  #  	# Disable xtrace as it would mangle the output.
  #  	setopt localoptions noxtrace
  #
  # +  sleep 0.03
  # +
  #  	# Store start time for job.
  #  	float -F duration=$EPOCHREALTIME
  log_info "Installing spaceship zsh theme..."
  _zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  git clone --depth 1 https://github.com/denysdovhan/spaceship-prompt.git "${_zsh_custom}/themes/spaceship-prompt"
  ln -s "${_zsh_custom}/themes/spaceship-prompt/spaceship.zsh-theme" "${_zsh_custom}/themes/spaceship.zsh-theme"

  log_info "Making sure directories exist..."
  mkdir -p "${HOME}/.config/alacritty/"
  mkdir -p "${HOME}/.config/tmux/"

  log_info "Symlinking dotfiles..."
  pushd "${clone_location}" || exit
  ln -sf "$(readlink -f tmux.conf)" "${HOME}/.config/tmux/tmux.conf"
  ln -sf "$(readlink -f zshrc)" "${HOME}/.zshrc"

  # cp /usr/share/doc/alacritty/example/alacritty.yml "${HOME}/.config/alacritty"
  mv "${HOME}/.config/alacritty/alacritty.toml" "${HOME}/.config/alacritty/alacritty.toml.backup"
  ln -sf "$(readlink -f alacritty.toml)" "${HOME}/.config/alacritty/alacritty.toml"

  mv ~/.config/i3/scripts ~/.config/i3/scripts-original
  mv ~/.config/i3/config ~/.config/i3/config-original
  ln -sf "$(readlink -f i3-scripts)" ~/.config/i3/scripts
  ln -sf "$(readlink -f i3-config-endeavour)" ~/.config/i3/config
  popd || exit

  log_info 'Installing Tmux Plugin Manager...'
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm --depth=1
  log_info 'Installing Tmux Plugins...'
  ~/.tmux/plugins/tpm/scripts/install_plugins.sh
  log_info 'Tmux Plugins Installed...'
}

function install_text_editor() {
  local -r dotfiles_location="${HOME}/src/hposca/dotfiles"

  log_info "Cloning LazyVim..."
  git clone --depth 1 https://github.com/LazyVim/starter "${HOME}/.config/LazyVim"

  log_info "Symlinking dotfiles..."
  mkdir -p "${HOME}/.config/LazyVim/"
  pushd "${dotfiles_location}" || exit
  mv "${HOME}/.config/LazyVim/lua" "${HOME}/.config/LazyVim/lua-backup"
  ln -sf "$(readlink -f LazyVim/lua)" "${HOME}/.config/LazyVim/"
  ln -sf "$(readlink -f snippets)" "${HOME}/.config/LazyVim/"
  popd || exit

  log_info "Updating LazyVim with new plugins..."
  NVIM_APPNAME=LazyVim nvim --headless "+Lazy! sync" +qa
}

function enable_docker() {
  sudo systemctl enable docker.service
  sudo systemctl start docker.service
  sudo usermod -aG docker "${USER}"
  # NOTE: Will need to logout-login for it to take effect
}

# First time they were installed (all at once) it failed, running one by one, later, worked.
# This is why I'm installing them one by one
function install_clementine() {
  yay -Syu --noconfirm aur/clementine
  yay -Syu --noconfirm gstreamer
  yay -Syu --noconfirm gstreamer0.10-base-plugins
  yay -Syu --noconfirm gstreamer0.10-good-plugins
  yay -Syu --noconfirm gstreamer0.10-bad-plugins
  yay -Syu --noconfirm gstreamer0.10-ugly-plugins
}

function install_system76_stuff() {
  yay -Syu --noconfirm system76-dkms

  # For system76-power had to configure cargo before:
  # 	cat <<EOF >"${HOME}/.cargo/config"
  # [net]
  # git-fetch-with-cli = true
  # EOF
  # yay -Syu --noconfirm system76-dkms system76-driver system76-firmware system76-power
}

# Not tests, but these where the steps I had to do
function install_clevo_indicator() {
  mkdir -p "${HOME}/src/github/"
  pushd "${HOME}/src/github/" || return
  git clone git@github.com:dbeniamine/clevo-indicator.git
  popd || return
  pushd "${HOME}/src/github/clevo-indicator" || return
  make
  sudo chown root bin/clevo-indicator
  sudo chmod u+s bin/clevo-indicator
  sudo mv bin/clevo-indicator "${HOME}/.local/bin/"
  popd || return
}

function configure_syncthing() {
  sudo systemctl enable "syncthing@$(whoami).service"
  sudo systemctl start "syncthing@$(whoami).service"
  sed -i.bak 's;<address>127.0.0.1:8384</address>;<address>0.0.0.0:8384</address>;' "${HOME}/.local/state/syncthing/config.xml"
  sudo systemctl restart "syncthing@$(whoami).service"
  # NOTE: Have to enable access to port 22000 on the firewall
}

function enable_prometheus() {
  sudo systemctl enable prometheus-node-exporter.service
  sudo systemctl start prometheus-node-exporter.service
  # To verify if metrics are being exported:
  # curl http://localhost:9100/metrics
}

# NOT TESTED - Essentialy note taking
# Based on https://github.com/debauchee/barrier/issues/231#issuecomment-456327061
function generate_barrier_certs() {
  log_info "Generating certificates for barrier..."

  _barrier_base_dir="${HOME}/.local/share/barrier/"
  _ssl_dir="${_barrier_base_dir}/SSL/"
  _pem_path="${_ssl_dir}/Barrier.pem"
  _fingerprints_dir="${_ssl_dir}/Fingerprints/"
  _local_fingerprints_path="${_fingerprints_dir}/Local.txt"

  mkdir -p "${_fingerprints_dir}"
  pushd "${_ssl_dir}" || return
  openssl req -x509 -nodes -days 365 -subj /CN=Barrier -newkey rsa:4096 -keyout "${_pem_path}" -out "${_pem_path}"
  openssl x509 -fingerprint -sha1 -noout -in "${_pem_path}" >"${_local_fingerprints_path}"
  popd || return

  log_info "barrier certificates creation done."
}

function display_recommendations() {
  cat <<EOF
Don't forget to add the following lines into your /etc/profile :

# https://forum.endeavouros.com/t/ten-tweaks-for-eos-i3-wm-on-lenovo-with-high-dpi/10363
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_SCREEN_SCALE_FACTORS=0.99
export GDK_SCALE=1
export GDK_DPI_SCALE=0.80

---

And this line into your ~/.Xresources :

Xft.dpi: 120

---

It may be necessay to add a small sleep in spaceship's async.zsh to avoid rendering problems:
In /${HOME}/.oh-my-zsh/custom/themes/spaceship-prompt/async.zsh

diff --git a/async.zsh b/async.zsh
index de13e75..15740db 100644
--- a/async.zsh
+++ b/async.zsh
@@ -28,6 +28,8 @@ _async_job() {
 	# Disable xtrace as it would mangle the output.
 	setopt localoptions noxtrace

+  sleep 0.03

---
EOF
}

function install_tgz() {
  tgz_filename="${1}"
  download_url="${2}"
  inner_file_path="${3}"

  curl -s -Lo "${tgz_filename}" "${download_url}"
  tar xf "${tgz_filename}" -C "${HOME}/.local/bin/" "${inner_file_path}"
  rm -rf "${tgz_filename}"
}

ISTIOCTL_VERSION=1.20.2
function install_istioctl() {
  install_tgz "istioctl-${ISTIOCTL_VERSION}-linux-amd64.tar.gz" "https://github.com/istio/istio/releases/download/${ISTIOCTL_VERSION}/istioctl-${ISTIOCTL_VERSION}-linux-amd64.tar.gz" "istioctl"
}

function main() {
  SECONDS=0
  packages_before=$(yay -Q | wc -l)

  log_info 'Beginning installation process ...'

  display_apps_infos "before"

  install_base
  install_terminal_tools
  install_desktop_tools

  install_development_tools
  # install_istioctl

  prepare_dotfiles
  install_text_editor

  enable_docker
  # install_clementine

  # xfce_caps_as_control
  # install_system76_stuff
  # install_clevo_indicator

  configure_syncthing
  enable_prometheus
  generate_barrier_certs

  display_recommendations

  packages_after=$(yay -Q | wc -l)
  local -r duration=${SECONDS}

  log_info "Total number of packages before process: ${packages_before}"
  log_info "Total number of packages after process : ${packages_after}"
  log_info "The entire installation process took $((duration / 60)) minutes and $((duration % 60)) seconds."

  display_apps_infos "after"

  log_warn "NOTE: It's recommended that you reboot your computer now."
}

main "${@}"
