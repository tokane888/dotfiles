#!/bin/bash

APT_PACKAGES=(
  apt-rdepends
  bash-completion
  cloc            # cloc . --vcs=gitでソース行数等カウント
  ethtool         # Wake on LAN用
  exuberant-ctags # tags自動生成
  ffmpeg
  gcc
  gpg
  g++
  jq
  locales # docker上で日本語使うため
  make
  nmap
  npm
  openssh-server
  peco
  python3
  python3-pip
  python3-venv # vimのblack pluginが依存
  silversearcher-ag
  tmux
  tree
  # universal-ctags # tags自動生成。見つからないため一旦削除
  unzip
  vagrant
  vim
  wget
  zip
  zsh
)

APT_REPOS=(
  ppa:jonathonf/vim
)

UBUNTU_APT_PACKAGES=(
  default-jre   # plantuml対応
  fonts-ipafont # plantuml対応
  graphviz      # plantuml対応
  sshpass
  taskwarrior
  timewarrior
)

MAIN_PC_APT_PACKAGES=(
  autoconf
  autokey-gtk
  autotools-dev
  build-essential
  cheese
  code
  copyq
  google-chrome-stable
  ibus-mozc
  kbd
  libreoffice-calc
  libreoffice-impress
  libx11-dev
  pinta
  solaar
  translate-shell # 右記のようなコマンドで翻訳 trans :ja "hello"
  wireshark
  xclip
  zsh
)

MAIN_PC_APT_REPOS=(
  ppa:hluk/copyq
)

MAIN_PC_SNAP_PACKAGES=(
  xmind
)

RPM_PACKAGES=(
  bash-completion
  cmake
  gcc # vimビルド時に使用
  golang
  make
  man-pages
  ncurses-devel # vimビルド時に使用
  tree
  unzip
  wget
  yum-utils
  zip
)

RPM_REPOS=(
  epel-release
)

PIP3_PACKAGES=(
  icdiff
  msgpack
  pynvim
  ruff
)

REAL_PIP3_PACKAGES=(
  timew-report
  togglCli
)

MAIN_PIP3_PACKAGES=(
  gnome-extensions-cli
)
