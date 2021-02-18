#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

LOCAL_BIN="${HOME}/.local/bin"

echo "Installing tfenv"
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
ln -s ~/.tfenv/bin/* "$LOCAL_BIN"

echo "Installing tgenv"
git clone https://github.com/cunymatthieu/tgenv.git ~/.tgenv
ln -s ~/.tgenv/bin/* "$LOCAL_BIN"

echo "Installing kubectx and kubens"
tmp_page=$(mktemp)
curl -s https://api.github.com/repos/ahmetb/kubectx/releases/latest -o "$tmp_page"
addresses=$(jq -r '.assets[] | select(.name | endswith("linux_x86_64.tar.gz")) | {url: .browser_download_url, name: .name}' "$tmp_page")

echo "$addresses"

echo "Installing kubens"
kubens_filename=$(echo "$addresses" | jq -r 'select(.name | contains("kubens")) | .name')
kubens_url=$(echo "$addresses" | jq -r 'select(.name | contains("kubens")) | .url')
echo "$kubens_filename"
echo "$kubens_url"

wget "$kubens_url"
tar -xvf "$kubens_filename" -C "${LOCAL_BIN}/" kubens

echo "Installing kubectx"
kubectx_filename=$(echo "$addresses" | jq -r 'select(.name | contains("kubectx")) | .name')
kubectx_url=$(echo "$addresses" | jq -r 'select(.name | contains("kubectx")) | .url')
echo "$kubectx_filename"
echo "$kubectx_url"

wget "$kubectx_url"
tar -xvf "$kubectx_filename" -C "${LOCAL_BIN}/" kubectx

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

echo "Installing k9s"
tmp_page=$(mktemp)
curl -s https://api.github.com/repos/derailed/k9s/releases/latest -o "$tmp_page"
addresses=$(jq -r '.assets[] | select(.name | endswith("Linux_x86_64.tar.gz")) | {url: .browser_download_url, name: .name}' "$tmp_page")
k9s_filename=$(echo "$addresses" | jq -r '.name')
k9s_url=$(echo "$addresses" | jq -r '.url')

wget "$k9s_url"
tar -xvf "${k9s_filename}" -C "${LOCAL_BIN}/" "k9s"

echo "Installing gh_cli"
tmp_page=$(mktemp)
curl -s https://api.github.com/repos/cli/cli/releases/latest -o "$tmp_page"
addresses=$(jq -r '.assets[] | select(.name | endswith("linux_amd64.tar.gz")) | {url: .browser_download_url, name: .name}' "$tmp_page")
gh_cli_filename=$(echo "$addresses" | jq -r '.name')
gh_cli_url=$(echo "$addresses" | jq -r '.url')

wget "$gh_cli_url"
tar -xvf "${gh_cli_filename}" --strip-components 2 -C "${LOCAL_BIN}/" "${gh_cli_filename%.*.*}/bin/gh"
