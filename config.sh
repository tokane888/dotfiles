#!/bin/bash

DOT_FILES_DIR=".local/dotfiles/"
APT_PACKAGES=(
  bash-completion
  # build-essential # vim補完するYouCompleteMeが依存
  # cmake           # vim補完するYouCompleteMeが依存
  gcc
  # libclang-dev # vim補完するYouCompleteMeが依存
  # locales      # docker上で日本語使うため
  make
  npm
  openssh-server
  # python3-dev # vim補完するYouCompleteMeが依存
  tree
  unzip
  vim
  wget
  zip
)

UBUNTU_PACKAGES=(
  golang-go
)

APT_REPOS=(
  ppa:longsleep/golang-backports
  ppa:jonathonf/vim
)

UBUNTU_PURGE_PACKAGES=(
  bluez*
  brasero*
  cheese*
  dnsutils
  empathy*
  espeak-ng-data:amd64
  evolution-data-server*
  gnome-bluetooth
  gnome-orca
  ibus-pinyin
  libreoffice-*
  mobile-broadband-provider-inf*
  mythes-en-us
  openssh-client
  printer-driver-*
  printer-driver-foo2zjs*
  rhythmbox*
  shotwell*
  simple-scan
  speech-dispatcher*
  thunderbird*
  transmission-*
  ubuntu-web-launchers
  unity-lens-*
  xul-ext-ubufox
)

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

GO_GETS=(
  github.com/golang/dep/cmd/dep
)

GO_GETS_UBUNTU=(
  # 32bitのarmはサポート外なのでラズパイでは使用不可
  # https://github.com/go-delve/delve/issues/20
  github.com/go-delve/delve/cmd/dlv
)
