#!/usr/bin/env bash

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

UBUNTU_RELEASE=focal
LOCAL_BIN="${HOME}/.local/bin"

function log() {
  local -r color="${1}"
  local -r message="${2}"
  local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  local -r nocolor='\033[0m'

  echo -e "\n[${timestamp}] ${color}${message}${nocolor}\n"
}

function log_info() {
  local -r message="${1}"
  local -r green='\033[0;32m'

  log "${green}" "${message}"
}

function log_warn() {
  local -r message="${1}"
  local -r green='\033[0;32m'
  local -r yellow='\033[1;33m'

  log "${yellow}" "${message}"
}

function install_base_packages() {
  log_warn "Please provide your super user password so the process can install all the required packages ..."

  # We need to `declare` the functions or else they will not be available
  # inside sudo's subshell
  sudo su -c "
    $(declare -f log)
    $(declare -f log_info)

    apt-get update
    log_info 'Upgrading all current packages to latest version ...'
    apt-get upgrade -y

    log_info 'Installing pre-requisite packages ...'
    apt-get install -y curl wget

    log_info 'Adding docker keys ...'
    apt-key adv --fetch-keys https://download.docker.com/linux/ubuntu/gpg
    add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu ${UBUNTU_RELEASE} stable'

    log_info 'Adding oracle keys ...'
    apt-key adv --fetch-keys http://www.virtualbox.org/download/oracle_vbox.asc
    apt-key adv --fetch-keys http://www.virtualbox.org/download/oracle_vbox_2016.asc
    add-apt-repository 'deb http://download.virtualbox.org/virtualbox/debian ${UBUNTU_RELEASE} contrib'

    log_info 'Adding mozilla ppa ...'
    add-apt-repository --yes 'ppa:ubuntu-mozilla-daily/ppa'

    log_info 'Adding enpass keys ...'
    apt-key adv --fetch-keys https://apt.enpass.io/keys/enpass-linux.key
    add-apt-repository 'deb https://apt.enpass.io/ stable main'

    apt-get update
    log_info 'Installing packages ...'
    apt-get install -y \
      barrier \
      digikam \
      dropbox \
      enpass \
      gnucash \
      gnupg \
      kazam \
      pass \
      qbittorrent \
      vlc \
      \
      playonlinux \
      steam \
      \
      chromium \
      firefox \
      firefox-trunk \
      \
      boxes \
      fonts-powerline \
      graphviz \
      guake \
      jq \
      neovim \
      scrot \
      silversearcher-ag \
      tmux \
      tree \
      xclip \
      zsh \
      \
      gkrellm \
      gparted \
      htop \
      iftop \
      iotop \
      ncdu \
      \
      exuberant-ctags \
      python3 \
      python3-ipdb \
      python3-pip \
      shellcheck \
      vagrant \
      yamllint \
      \
      giggle \
      git \
      gitg \
      meld \
      qgit \
      tig \
      \
      dnsutils \
      ipcalc \
      lynx \
      whois \
      \
      apt-transport-https \
      ca-certificates \
      curl \
      software-properties-common \
      gnupg-agent \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      \
      virtualbox \
      virtualbox-qt \
      virtualbox-dkms

    # https://askubuntu.com/questions/1290262/unable-to-install-bat-error-trying-to-overwrite-usr-crates2-json-which
    apt install -y  -o Dpkg::Options::='--force-overwrite' bat ripgrep

    log_info 'Adding user to docker group ...'
    usermod -aG docker $(whoami)

    log_info 'Upgrading pip ...'
    pip3 install --upgrade pip

    update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 100
    update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 100
    update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 100
    "
}

function install_python_packages() {
  log_info "Installing python packages..."

  pip3 install --user \
    awscli \
    black \
    boto3 \
    bpytop \
    diagrams \
    docker-compose \
    ipython \
    jedi \
    mkdocs \
    neovim \
    powerline-status \
    pre-commit \
    psutil \
    pyftpdlib \
    pyopenssl \
    ranger-fm \
    rich \
    tldr \
    youtube-dl
}

function simple_git_clone() {
  local -r name="${1}"
  local -r repository="${2}"
  local -r location="${3}"

  log_info "Installing ${name}"
  git clone "${repository}" "${location}"
  ln -s "${location}"/bin/* "$LOCAL_BIN"
}

function simple_latest_github_release() {
  local -r name="${1}"
  local -r user_repo="${2}"
  local -r match="${3}"

  log_info "Installing ${name}"

  local -r tmp_page=$(mktemp)
  curl -s "https://api.github.com/repos/${user_repo}/releases/latest" -o "$tmp_page"
  local -r addresses=$(jq -r ".assets[] | select(.name | endswith(\"$match\")) | {url: .browser_download_url, name: .name}" "$tmp_page")
  local -r filename=$(echo "$addresses" | jq -r "select(.name | contains(\"$name\")) | .name")
  local -r url=$(echo "$addresses" | jq -r "select(.name | contains(\"$name\")) | .url")

  wget "$url"
  tar -xvf "$filename" -C "${LOCAL_BIN}/" "${name}"
}

function simple_latest_github_release_binary() {
  local -r name="${1}"
  local -r user_repo="${2}"
  local -r match="${3}"

  log_info "Installing ${name}"

  local -r tmp_page=$(mktemp)
  curl -s "https://api.github.com/repos/${user_repo}/releases/latest" -o "$tmp_page"
  local -r addresses=$(jq -r ".assets[] | select(.name | endswith(\"$match\")) | {url: .browser_download_url, name: .name}" "$tmp_page")
  local -r filename=$(echo "$addresses" | jq -r "select(.name | contains(\"$name\")) | .name")
  local -r url=$(echo "$addresses" | jq -r "select(.name | contains(\"$name\")) | .url")

  wget "$url"
  chmod +x "$filename"
  mv "$filename" "${LOCAL_BIN}/${name}"
}

function inner_path_latest_github_release() {
  local -r name="${1}"
  local -r user_repo="${2}"
  local -r match="${3}"
  local -r strip_components="${4}"
  local -r file_path="${5}"

  log_info "Installing ${name}"

  local -r tmp_page=$(mktemp)
  curl -s "https://api.github.com/repos/${user_repo}/releases/latest" -o "$tmp_page"
  local -r addresses=$(jq -r ".assets[] | select(.name | endswith(\"$match\")) | {url: .browser_download_url, name: .name}" "$tmp_page")
  local -r filename=$(echo "$addresses" | jq -r "select(.name | contains(\"$name\")) | .name")
  local -r url=$(echo "$addresses" | jq -r "select(.name | contains(\"$name\")) | .url")

  wget "$url"
  tar -xvf "$filename" --strip-components "${strip_components}" -C "${LOCAL_BIN}/" "${filename%.*.*}/${file_path}"
}

function install_kubectl() {
  log_info "Installing kubectl"

  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
  echo "$(<kubectl.sha256) kubectl" | sha256sum --check || { echo "SHA doesn't match, exiting"; exit 1; }
  chmod +x ./kubectl
  mv ./kubectl "${LOCAL_BIN}/kubectl"
}

function install_golang() {
  local -r download_page="https://golang.org/dl/"

  local -r tmp_page=$(mktemp)
  curl -s "$download_page" -o "$tmp_page"

  local -r latest_version=$(grep linux-amd64 "$tmp_page" | grep 'download downloadBox' | cut -d'"' -f4 | cut -d'/' -f3)
  local -r sha=$(grep -A10 "$latest_version" "$tmp_page" | grep "<td><tt>" | sed 's/<[^>]*>//g' | tr -d ' ')

  wget "$download_page$latest_version"
  echo "${sha} ${latest_version}" | sha256sum --check || { echo "SHA doesn't match, exiting"; exit 1; }
  sudo tar -C /usr/local -xzf "$latest_version"

  # Do not forget to add these environment variables into your ~/.bashrc ~/.zshrc ~/.fishrc file
  # export GOROOT=/usr/local/go
  # export GOPATH=$HOME/src/go
  # export PATH=$PATH:$GOPATH/bin:$GOROOT/bin
}

function install_terminal_tools() {
    log_info "Installing oh-my-zsh ..."
    curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
    chsh -s "$(command -v zsh)"

    log_info "Installing zsh plugins..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

    log_info "Installing fzf ..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all

    log_info "Installing plug ..."
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    # If we want to install the latest version of bat:
    #
    # log_info "Installing batcat ..."
    # # With the great help of https://geraldonit.com/2019/01/15/how-to-download-the-latest-github-repo-release-via-command-line/
    # _tmp_dir="$(mktemp -d)"
    # LOCATION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest \
    # | grep "tag_name" \
    # | awk '{print "https://github.com/sharkdp/bat/archive/" substr($2, 2, length($2)-3) ".deb"}') \
    # ; curl -L -o "${_tmp_dir}/bat.deb" "${LOCATION}"

    log_info "Configuring bat ..."
    # https://github.com/sharkdp/bat#on-ubuntu-using-apt
    mkdir -p ~/.local/bin
    ln -s /usr/bin/batcat ~/.local/bin/bat

    log_info "Installing dotfiles ..."
    local -r dotfiles_dir=~/src/hposca/dotfiles/
    if [[ ! -d "${dotfiles_dir}" ]]; then
      mkdir -p "${dotfiles_dir}"
      git clone https://github.com/hposca/dotfiles.git "${dotfiles_dir}"
    else
      pushd "${dotfiles_dir}" || exit
      git pull
      popd || exit
    fi
    log_info "Creating symbolic links"
    ln -sf "${dotfiles_dir}"/tmux.conf ~/.tmux.conf
    ln -sf "${dotfiles_dir}"/zshrc ~/.zshrc
    mkdir -p ~/.config/nvim/
    ln -sf "${dotfiles_dir}"/init.vim ~/.config/nvim/init.vim
    ln -sf "${dotfiles_dir}"/vimrcs ~/.config/nvim/vimrcs
    ln -sf "${dotfiles_dir}"/philips.zsh-theme ~/.oh-my-zsh/custom/philips.zsh-theme

    log_info "Installing neovim plugins ..."
    nvim "+silent! PlugInstall!" +qall!

    simple_git_clone tfenv https://github.com/tfutils/tfenv.git      "${HOME}/.tfenv"
    simple_git_clone tgenv https://github.com/cunymatthieu/tgenv.git "${HOME}/.tgenv"

    simple_latest_github_release kubens  ahmetb/kubectx linux_x86_64.tar.gz
    simple_latest_github_release kubectx ahmetb/kubectx linux_x86_64.tar.gz
    simple_latest_github_release k9s     derailed/k9s   Linux_x86_64.tar.gz

    inner_path_latest_github_release delta dandavison/delta x86_64-unknown-linux-gnu.tar.gz 1 delta
    inner_path_latest_github_release gh    cli/cli          linux_amd64.tar.gz              2 bin/gh

    simple_latest_github_release_binary aws-vault 99designs/aws-vault linux-amd64

    install_kubectl
    install_golang
}

function main() {
  SECONDS=0
  packages_before=$(dpkg --get-selections | wc -l)

  log_info 'Beginning installation process ...'

  install_base_packages
  install_python_packages
  install_terminal_tools

  packages_after=$(dpkg --get-selections | wc -l)
  local -r duration=${SECONDS}

  log_info "Total number of packages before process: ${packages_before}"
  log_info "Total number of packages after process : ${packages_after}"
  log_info "The entire installation process took $((duration / 60)) minutes and $((duration % 60)) seconds."

  log_warn "NOTE: It's recommended that you reboot your computer now."
}

main "${@}"
