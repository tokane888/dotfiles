#!/bin/bash

APT_PACKAGES=(
  apt-rdepends
  bash-completion
  cloc            # cloc . --vcs=gitでソース行数等カウント
  ethtool         # Wake on LAN用
  exuberant-ctags # tags自動生成
  ffmpeg
  gcc
  gh
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
  rename
  silversearcher-ag
  tmux
  tree
  # universal-ctags # tags自動生成。見つからないため一旦削除
  unzip
  vim
  zip
  zsh
)

APT_REPOS=(
  ppa:jonathonf/vim
  ppa:dotnet/backports
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
  brightness-controller
  build-essential
  cheese
  code
  copyq
  dotnet-sdk-8.0
  gcc-12
  google-chrome-stable
  ibus-mozc
  kbd
  libreoffice-calc
  libreoffice-impress
  libx11-dev
  pinta
  p7zip
  solaar
  translate-shell # 右記のようなコマンドで翻訳 trans :ja "hello"
  vlc
  wireshark
  xclip
  zsh
)

MAIN_PC_APT_REPOS=(
  ppa:hluk/copyq
  ppa:apandada1/brightness-controller
)

MAIN_PC_SNAP_PACKAGES=(
  aws-cli
  teams-for-linux
  xmind
  yq
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

NPM_PACKAGES=(
  depcheck # package.json内の不要なパッケージ検知
  markuplint
  typescript
)
