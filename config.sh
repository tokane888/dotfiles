#!/bin/bash

DOT_FILES_DIR=".local/dotfiles/"
APT_PACKAGES=(
  curl
  gcc
  golang-go
  make
  nodejs
  npm
  openssh-server
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
)
