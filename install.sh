#!/bin/bash
. config.sh

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
}

install_apt_packages() {
  apt-get install -y ${APT_PACKAGES[*]}
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
}

set_locale() {
  sed -i "s/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/g" /etc/locale.gen
  locale-gen ja_JP.utf8
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

  install_vim_plugins
  set_locale

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
