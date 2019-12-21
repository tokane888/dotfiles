#!/bin/bash
. config.sh
. generate_bashrc.sh

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

  # 複数リポジトリを1コマンドで追加するとエラーになるので1つずつ行う
  for repo in ${APT_REPOS[@]}; do
    add-apt-repository -y $repo
  done

  # リポジトリの追加にcurlが必要なため、先にインストール
  apt-get install -y curl
  # node, npmの最新版取得可能なリポジトリ追加
  curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -
}

add_rpm_repository() {
  for repo in ${RPM_REPOS[@]}; do
    yum install -y $repo
  done
}

install_apt_packages() {
  apt-get install -y ${APT_PACKAGES[*]}
}

install_rpm_packages() {
  yum install -y ${RPM_PACKAGES[*]}
}

# 最新のvimがおいてあるリポジトリが見つからないのでソースからビルド
install_latest_vim_on_cent() {
  yum erase -y vim

  pushd .
  mkdir -p vim
  cd vim
  wget https://github.com/vim/vim/archive/master.zip
  unzip master.zip
  cd vim-master/src
  ./configure --enable-gui=no --enable-python3interp
  make
  make install
  [ ! -e /usr/bin/vim ] && ln -s /root/.local/dotfiles/vim/vim-master/src/vim /usr/bin/vim
  popd
}

setup_yum() {
  if $(can_use_command "yum"); then
    # dockerのyum設定から、manpageを取得しない設定削除
    sed -i s/tsflags=nodocs//g /etc/yum.conf
  fi
}

go_get() {
  mkdir -p $HOME/.go
  # GOPATH, PATH設定は.bashrcでも行っているが、PS1変数未定義などで弾かれる。
  # そのため、go getをここで実行するためにGOPATH, PATHをexport
  export GOPATH=$HOME/.go
  export PATH=$PATH:$GOPATH/bin
  for target in ${GO_GETS[@]}; do
    go get -u $target
  done
}

install_vim_plugins() {
  mkdir -p ~/.vim/bundle/
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  vim +PluginInstall +qall
  python3 ~/.vim/bundle/YouCompleteMe/install.py --go-completer
  # メッセージがコンソール画面に収まらないと手入力が必要になるのでsilentにバイナリインストール
  vim +'silent :GoInstallBinaries' +qall
}

is_valid_exit_code() {
  local cmd=$1
  $cmd
}

set_locale() {
  # centOSでは元から日本語入力可能なので対応不要。ラズパイは不明
  if [ $(command -v apt) ]; then
    # docker上で日本語入力を可能に
    sed -i "s/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/g" /etc/locale.gen
    locale-gen ja_JP.utf8
  fi
}

set_timezone() {
  if [ $(date +%Z) = "UTC" ]; then
    if is_valid_exit_code "timedatectl"; then
      timedatectl set-timezone Asia/Tokyo
    else
      apt install -y tzdata
    fi
    # TODO: ラズパイでもこの対応で良いか確認
  fi
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
    # TODO: manページ対応
  elif $(can_use_command "yum"); then
    setup_yum
    add_rpm_repository
    install_rpm_packages
    install_latest_vim_on_cent
  fi
  go_get

  local dot_files=$(ls -a | grep '^\..*' | grep -vE '(^\.$|^\.\.$|\.git$)')
  for file in ${dot_files[@]}; do
    [ ! -e ~/$file ] && ln -s ${DOT_FILES_DIR}$file ~/$file
  done

  install_vim_plugins
  set_locale
  set_timezone
  generate_bashrc

  local end_time=$(date +%s)
  local run_time=$((end_time - start_time))
  echo "$run_time 秒で初期化"
  # . .bashrc は、デフォルトの.bashrcに、PS1が設定されていない場合(.sh実行時など)は
  # 実行終了する記載がある場合があるので手動で読み込む
  echo ". ~/.bashrc を実行して下さい"
  echo ".gitconfigのuser, passは必要に応じて修正して下さい"
}

main
