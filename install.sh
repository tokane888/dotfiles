#!/bin/bash

## git cloneの上、インストール処理実行。
## curlでダウンロードして実効する想定。

set -eux

get_home() {
  # ラズパイ、Cent上では、sudo時に$HOME=/root になってしまうので対応
  if [[ -v SUDO_USER ]]; then
    echo $(eval echo ~${SUDO_USER})
  else
    echo $HOME
  fi
}

main() {
  if [ $(command -v apt) ]; then
    sed -i -e 's/\(deb\|deb-src\) http:\/\/archive.ubuntu.com/\1 http:\/\/jp.archive.ubuntu.com/g' /etc/apt/sources.list
    apt-get update -y
    apt-get install -y git sudo
  elif [ $(command -v yum) ]; then
    yum remove -y git
    yum install -y https://centos7.iuscommunity.org/ius-release.rpm
    yum install -y git2u sudo
  fi
  mkdir -p ~/.local
  cd ~/.local
  if [ ! -d /root/.local/dotfiles ]; then
    git clone https://github.com/tokane888/dotfiles.git
  fi
  cd ~/.local/dotfiles
  sudo ./core.sh $(get_home) > dotfiles.log 2>&1
}

main
