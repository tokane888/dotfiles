#!/bin/bash

DOT_FILES_DIR=".local/dotfiles/"
APT_PACKAGES=(
  build-essential # vim補完するYouCompleteMeが依存
  cmake # vim補完するYouCompleteMeが依存
  curl
  gcc
  golang-go
  locales # docker上で日本語使うため
  make
  nodejs
  npm
  openssh-server
  python3-dev # vim補完するYouCompleteMeが依存
  tree
  vim
  wget
)

APT_REPOS=(
  ppa:longsleep/golang-backports
  ppa:jonathonf/vim
)

GO_GETS=(
  github.com/golang/dep/cmd/dep
  github.com/go-delve/delve/cmd/dlv
)
