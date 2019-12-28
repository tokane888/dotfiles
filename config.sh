#!/bin/bash

DOT_FILES_DIR=".local/dotfiles/"
APT_PACKAGES=(
  build-essential # vim補完するYouCompleteMeが依存
  cmake # vim補完するYouCompleteMeが依存
  apt-file # debパッケージに含まれるファイル一覧をリポジトリから取得
  gcc
  golang-go
  libclang-dev # vim補完するYouCompleteMeが依存
  locales # docker上で日本語使うため
  make
  nodejs
  openssh-server
  python3-dev # vim補完するYouCompleteMeが依存
  tree
  tzdata
  unzip
  vim
  wget
  zip
)

APT_REPOS=(
  ppa:longsleep/golang-backports
  ppa:jonathonf/vim
)

RPM_PACKAGES=(
  bash-completion
  cmake
  gcc # vimビルド時に使用
  gcc-c++ # YouCompleteMeが依存
  golang
  make
  man-pages
  ncurses-devel # vimビルド時に使用
  python3-devel # YouCompleteMeが依存
  tree
  unzip
  wget
  yum-utils
  zip
)

RPM_REPOS=(
  epel-release
)

GO_GETS=(
  github.com/golang/dep/cmd/dep
  github.com/go-delve/delve/cmd/dlv
)
