#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo "Installing tfenv"
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
ln -s ~/.tfenv/bin/* ~/.local/bin

echo "Installing tgenv"
git clone https://github.com/cunymatthieu/tgenv.git ~/.tgenv
ln -s ~/.tgenv/bin/* ~/.local/bin

echo "Installing pre-commit"
pip3 install --user pre-commit

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
tar -xvf "$kubens_filename" -C ~/bin/ kubens

echo "Installing kubectx"
kubectx_filename=$(echo "$addresses" | jq -r 'select(.name | contains("kubectx")) | .name')
kubectx_url=$(echo "$addresses" | jq -r 'select(.name | contains("kubectx")) | .url')
echo "$kubectx_filename"
echo "$kubectx_url"

wget "$kubectx_url"
tar -xvf "$kubectx_filename" -C ~/bin/ kubectx

echo "Installing kubectl"

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(<kubectl.sha256) kubectl" | sha256sum --check || { echo "SHA doesn't match, exiting"; exit 1; }
chmod +x ./kubectl
mv ./kubectl ~/.local/bin/kubectl
