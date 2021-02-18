#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

LOCAL_BIN="${HOME}/.local/bin"

echo "Installing kubectl"

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(<kubectl.sha256) kubectl" | sha256sum --check || { echo "SHA doesn't match, exiting"; exit 1; }
chmod +x ./kubectl
mv ./kubectl "${LOCAL_BIN}/kubectl"

echo "Installing delta diff output"
tmp_page=$(mktemp)
curl -s https://api.github.com/repos/dandavison/delta/releases/latest -o "$tmp_page"
addresses=$(jq -r '.assets[] | select(.name | endswith("x86_64-unknown-linux-gnu.tar.gz")) | {url: .browser_download_url, name: .name}' "$tmp_page")
delta_filename=$(echo "$addresses" | jq -r '.name')
delta_url=$(echo "$addresses" | jq -r '.url')

wget "$delta_url"
tar -xvf "${delta_filename}" --strip-components 1 -C "${LOCAL_BIN}/" "${delta_filename%.*.*}/delta"

echo "Installing gh_cli"
tmp_page=$(mktemp)
curl -s https://api.github.com/repos/cli/cli/releases/latest -o "$tmp_page"
addresses=$(jq -r '.assets[] | select(.name | endswith("linux_amd64.tar.gz")) | {url: .browser_download_url, name: .name}' "$tmp_page")
gh_cli_filename=$(echo "$addresses" | jq -r '.name')
gh_cli_url=$(echo "$addresses" | jq -r '.url')

wget "$gh_cli_url"
tar -xvf "${gh_cli_filename}" --strip-components 2 -C "${LOCAL_BIN}/" "${gh_cli_filename%.*.*}/bin/gh"
