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
)

GO_GETS=(
  github.com/golang/dep/cmd/dep
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
  apt-get install -y ${APT_PACKAGES[*]}
}

go_get() {
  mkdir $HOME/.go
  # TODO: ここでのPATH設定は暫定対応。.bashrcなどへ整理する
  export GOPATH=$HOME/.go
  export PATH=$PATH:$GOPATH/bin
  for target in ${GO_GETS[@]}; do
    go get -u $target
  done
}

main() {
  start_time=$(date +%s)

  if ! $(is_root); then
    echo "Please run with sudo."
    exit 1
  fi

  if $(can_use_command "apt"); then
    add_apt_repository
    install_apt_packages
  fi
  # TODO: yum対応
  go_get

  for file in ${DOT_FILES[@]}; do
    [ ! -e ~/$file ] && ln -s ${DOT_FILES_DIR}$file ~/$file
  done
  # TODO: 将来的にはzshに移行し、.zshrcそのままコピー
  cat .bashrc >>~/$.bashrc

  end_time=$(date +%s)
  run_time=$((end_time - start_time))
  echo "$run_time 秒で初期化"
}

main
