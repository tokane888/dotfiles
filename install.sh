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
  apt-get install -y software-properties-common
  # TODO: ラズパイの場合には当該リポジトリからダウンロード不可。
  #       かつデフォルトのリポジトリから比較的新しいバージョンがインストール可能。
  #       なのでラズパイの場合は当該リポジトリの追加を行わない
  # add-apt-repository実行で当該repositoryに対するapt updateも行われる
  add-apt-repository -y ppa:longsleep/golang-backports
}

install_apt_packages() {
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
    apt-get update -y
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
