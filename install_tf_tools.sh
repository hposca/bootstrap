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
