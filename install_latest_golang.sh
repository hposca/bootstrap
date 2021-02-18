#!/usr/bin/env bash

# Installs the latest version of golang

DOWNLOAD_PAGE="https://golang.org/dl/"
# Get current version of Go for 64-bit Linux
LATEST_VERSION=$(curl -s "$DOWNLOAD_PAGE" | grep linux-amd64 | grep 'download downloadBox' | cut -d'"' -f4 | cut -d'/' -f3)

# Download Go
wget "$DOWNLOAD_PAGE$LATEST_VERSION"

# Unpack file to /usr/local
sudo tar -C /usr/local -xzf "$LATEST_VERSION"

# Do not forget to add these environment variables into your ~/.bashrc ~/.zshrc ~/.fishrc file
# export GOROOT=/usr/local/go
# export GOPATH=$HOME/src/go
# export PATH=$PATH:$GOPATH/bin:$GOROOT/bin

# Remove Go .tar.gz
# rm $LATEST_VERSION
