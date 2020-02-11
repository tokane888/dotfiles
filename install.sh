#!/bin/bash

## git cloneの上、インストール処理実行。
## curlでダウンロードして実効する想定。

set -eux

main() {
  if [ $(command -v apt) ]; then
    sed -i -e 's/\(deb\|deb-src\) http:\/\/archive.ubuntu.com/\1 http:\/\/jp.archive.ubuntu.com/g' /etc/apt/sources.list
    apt-get update -y
    apt-get install -y git sudo
    mkdir -p ~/.local
    cd ~/.local
    git clone https://github.com/tokane888/dotfiles.git
    cd ~/.local/dotfiles
    sudo ./install.sh
  elif [ $(command -v yum) ]; then
    yum remove -y git
    yum install -y https://centos7.iuscommunity.org/ius-release.rpm
    yum install -y git2u sudo
    mkdir -p ~/.local
    cd ~/.local
    git clone https://github.com/tokane888/dotfiles.git
    cd ~/.local/dotfiles
    sudo ./install.sh
  fi
}

main
