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

DOT_FILES=(
  .vimrc
  .bash_aliases
  .bashrc
)

set -eux

is_root() {
  [ ${EUID:-${UID}} = 0 ]
}

can_use_command() {
  local command=$1

  [ -x "$(command -v $command)" ]
}

add_apt_repository() {
  add-apt-repository -y ppa:longsleep/golang-backports
  apt-get update -y
  apt-get install -y golang-go
}

install_apt_packages() {
  apt-get update -y
  for package in ${APT_PACKAGES[@]}; do
    apt-get install -y $package
  done
}

main() {
  if ! $(is_root); then
    echo "Please run with sudo."
    exit 1
  fi

  if $(can_use_command "apt"); then
    add_apt_repository
    install_apt_packages
  fi
  # TODO: yum対応

  for file in ${DOT_FILES[@]}; do
    [ ! -e ~/$file ] && ln -s ${DOT_FILES_DIR}$file ~/$file
  done

  source ~/.bashrc
}

main
