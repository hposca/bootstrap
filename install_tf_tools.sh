#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# echo "Installing tfenv"
# git clone https://github.com/tfutils/tfenv.git ~/.tfenv
# ln -s ~/.tfenv/bin/* ~/.local/bin
#
# echo "Installing tgenv"
# git clone https://github.com/cunymatthieu/tgenv.git ~/.tgenv
# ln -s ~/.tgenv/bin/* ~/.local/bin

echo "Installing pre-commit"
pip3 install --user pre-commit
