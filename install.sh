#!/bin/bash

APT_PACKAGES=(
  curl
  sudo
  tree
  vim
)

set -eux

is_root() {
  [ ${EUID:-${UID}} = 0 ]
}

can_use_command() {
  local command=$1

  [ -x "$(command -v $command)" ]
}

install_apt_packages() {
  apt update -y
  for package in ${APT_PACKAGES[@]}; do
    apt install -y $package
  done
}

main() {
  if ! $(is_root); then
    echo "Please run with sudo."
    exit 1
  fi

  if $(can_use_command "apt"); then
    install_apt_packages
  fi
  # TODO: yum対応

  # TODO: .bashrc, .vimrc設定
}

main
