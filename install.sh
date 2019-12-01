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
  add-apt-repository -y ppa:longsleep/golang-backports
}

install_apt_packages() {
  apt-get install -y ${APT_PACKAGES[*]}
}

go_get() {
  mkdir -p $HOME/.go
  # TODO: ここでのPATH設定は暫定対応。.bashrcなどへ整理する
  export GOPATH=$HOME/.go
  export PATH=$PATH:$GOPATH/bin
  for target in ${GO_GETS[@]}; do
    go get -u $target
  done
}

main() {
  local start_time=$(date +%s)

  if ! $(is_root); then
    echo "Please run with sudo."
    exit 1
  fi

  if $(can_use_command "apt"); then
    add_apt_repository
    apt-get update -y
    install_apt_packages
  fi
  # TODO: yum対応
  go_get

  local dot_files=$(ls -a | grep '^\..*' | grep -vE '(^\.$|^\.\.$|\.git$)')
  for file in ${dot_files[@]}; do
    [ ! -e ~/$file ] && ln -s ${DOT_FILES_DIR}$file ~/$file
  done
  # TODO: 将来的にはzshに移行し、.zshrcそのままコピー
  cat .bashrc >>~/.bashrc
  # . .bashrc は、デフォルトの.bashrcに、PS1が設定されていない場合(.sh実行時など)は
  # 実行終了する記載がある場合があるので手動で読み込む

  local end_time=$(date +%s)
  local run_time=$((end_time - start_time))
  echo "$run_time 秒で初期化"
  echo ". ~/.bashrc を実行して下さい"
  echo ".gitconfigのuser, passは必要に応じて修正して下さい"
}

main
