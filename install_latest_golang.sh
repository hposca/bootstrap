#!/usr/bin/env bash

# Installs the latest version of golang

DOWNLOAD_PAGE="https://golang.org/dl/"

tmp_page=$(mktemp)
curl -s "$DOWNLOAD_PAGE" -o "$tmp_page"

# Get current version of Go for 64-bit Linux
LATEST_VERSION=$(grep linux-amd64 "$tmp_page" | grep 'download downloadBox' | cut -d'"' -f4 | cut -d'/' -f3)

SHA=$(grep -A10 "$LATEST_VERSION" "$tmp_page" | grep "<td><tt>" | sed 's/<[^>]*>//g' | tr -d ' ')

# Download Go
wget "$DOWNLOAD_PAGE$LATEST_VERSION"

sha_result=$(sha256sum "$LATEST_VERSION" | cut -d' ' -f1)
echo "$sha_result"
if [[ "$SHA" != "$sha_result" ]]; then
  echo "SHA doesn't match, aborting..."
  exit 1
fi

echo "SHA matched, proceding"

# Unpack file to /usr/local
sudo tar -C /usr/local -xzf "$LATEST_VERSION"

# Do not forget to add these environment variables into your ~/.bashrc ~/.zshrc ~/.fishrc file
# export GOROOT=/usr/local/go
# export GOPATH=$HOME/src/go
# export PATH=$PATH:$GOPATH/bin:$GOROOT/bin

# Remove Go .tar.gz
# rm $LATEST_VERSION
