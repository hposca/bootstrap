#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# LOCAL_BIN="${HOME}/.local/bin"
DOWNLOADS_DIR=".downloads"
SOURCES_DIR=".sources"

function polybar_install_required_packages {
  sudo apt install -y \
    build-essential \
    cmake \
    cmake-data \
    git \
    libcairo2-dev \
    libxcb-composite0-dev \
    libxcb-ewmh-dev \
    libxcb-icccm4-dev \
    libxcb-image0-dev \
    libxcb-randr0-dev \
    libxcb-util0-dev \
    libxcb1-dev \
    pkg-config \
    python3-packaging \
    python3-sphinx \
    python3-xcbgen \
    xcb-proto
}

function polybar_install_optional_packages {
  sudo apt install -y \
    i3-wm \
    libasound2-dev \
    libcurl4-openssl-dev \
    libjsoncpp-dev \
    libmpdclient-dev \
    libnl-genl-3-dev \
    libpulse-dev \
    libxcb-cursor-dev \
    libxcb-xkb-dev \
    libxcb-xrm-dev
}

function github_extract_latest {
  local -r name="${1}"
  local -r user_repo="${2}"
  local -r match="${3}"

  # log_info "Installing ${name}"

  local -r tmp_page=$(mktemp)
  curl -s "https://api.github.com/repos/${user_repo}/releases/latest" -o "$tmp_page"
  local -r addresses=$(jq -r ".assets[] | select(.name | endswith(\"$match\")) | {url: .browser_download_url, name: .name}" "$tmp_page")
  local -r filename=$(echo "$addresses" | jq -r "select(.name | contains(\"$name\")) | .name")
  local -r url=$(echo "$addresses" | jq -r "select(.name | contains(\"$name\")) | .url")

  mkdir -p "${DOWNLOADS_DIR}"
  wget "$url" --directory-prefix "${DOWNLOADS_DIR}"
  mkdir -p "${SOURCES_DIR}/${name}"
  tar -xvf "${DOWNLOADS_DIR}/${filename}" -C "${SOURCES_DIR}/${name}" --strip-components=1 &> /dev/null

  echo "${SOURCES_DIR}/${name}"
}

function install_polybar {
  # With the great help of https://github.com/polybar/polybar/wiki/Compiling
  polybar_install_required_packages
  polybar_install_optional_packages
  source_path=$(github_extract_latest polybar polybar/polybar tar.gz)

  pushd "${source_path}"
    mkdir build
    pushd build
      # TODO: Check if pyenv is installed and only run this if it is
      pyenv local system
      cmake ..
      make -j"$(nproc)"
      sudo make install
    popd
  popd

  mkdir -p ~/.config/polybar/
  cp "${source_path}/config" ~/.config/polybar/config
}

install_polybar "${@}"
