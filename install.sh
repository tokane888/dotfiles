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
  local go_repo="longsleep-ubuntu-golang-backports-xenial.list"
  local go_repo_path=/etc/apt/sources.list.d/$go_repo
  local code_name=$(lsb_release -cs)
  touch $go_repo_path
  echo "deb http://ppa.launchpad.net/longsleep/golang-backports/ubuntu $code_name main" >$go_repo_path
  echo "# deb-src http://ppa.launchpad.net/longsleep/golang-backports/ubuntu $code_name main" >>$go_repo_path
  apt-get update -y -o Dir::Etc::sourcelist="sources.list.d/$go_repo"
  # TODO: ラズパイ上では上記のrepo使えないので消す
  # 　　　　ラズパイだとgolang1.11が標準のrepoから落とせるのでそもそも別repoは不要
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
