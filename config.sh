#!/bin/bash

DOT_FILES_DIR=".local/dotfiles/"
APT_PACKAGES=(
  bash-completion
  build-essential # vim補完するYouCompleteMeが依存
  cmake           # vim補完するYouCompleteMeが依存
  exuberant-ctags # tags自動生成
  gcc
  g++
  libclang-dev # vim補完するYouCompleteMeが依存
  locales      # docker上で日本語使うため
  make
  npm
  openssh-server
  peco
  python3
  python3-dev # vim補完するYouCompleteMeが依存
  python3-pip
  silversearcher-ag
  tmux
  tree
  # universal-ctags # tags自動生成。見つからないため一旦削除
  unzip
  vim
  wget
  zip
  zsh
)

UBUNTU_PACKAGES=(
  mercurial # gvmが依存
  binutils  # gvmが依存
  bison     # gvmが依存
)

APT_REPOS=(
)

#UBUNTU_PURGE_PACKAGES=(
  #libreoffice-calc
  #libreoffice-draw
  #libreoffice-math
  #libreoffice-writer
  #mythes-en-us
  #rhythmbox
  #simple-scan
  #thunderbird
  #xul-ext-ubufox
#)

RPM_PACKAGES=(
  bash-completion
  cmake
  gcc     # vimビルド時に使用
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

# GO_GETS=(
#   github.com/golang/dep/cmd/dep
# )

GO_GETS_UBUNTU=(
  # 32bitのarmはサポート外なのでラズパイでは使用不可
  # https://github.com/go-delve/delve/issues/20
  github.com/go-delve/delve/cmd/dlv
)

PIP3_PACKAGES=(
  autopep8
  flake8
  msgpack
  pynvim
)