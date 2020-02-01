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

get_os() {
  echo $(
    . /etc/os-release
    echo $ID
  )
}

get_home() {
  # ラズパイ、Cent上では、sudo時に$HOME=/root になってしまうので対応
  if [[ -v SUDO_USER ]]; then
    echo $(eval echo ~${SUDO_USER})
  else
    echo $HOME
  fi
}

add_apt_repository() {
  if [ "$(get_os)" == "ubuntu" ]; then
    apt-get install -y software-properties-common
    # TODO: ラズパイの場合には当該リポジトリからダウンロード不可。
    #       かつデフォルトのリポジトリから比較的新しいバージョンがインストール可能。
    #       なのでラズパイの場合は当該リポジトリの追加を行わない

    # 複数リポジトリを1コマンドで追加するとエラーになるので1つずつ行う
    for repo in ${APT_REPOS[@]}; do
      add-apt-repository -y $repo
    done
  fi

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
  if [ "$(get_os)" == "ubuntu" ]; then
    apt-get install -y ${UBUNTU_PACKAGES[*]}
  fi
}

install_rpm_packages() {
  yum install -y ${RPM_PACKAGES[*]}
}

install_from_src() {
  # TODO: dockerの場合、"go version"でSegmentation faultになり、実行失敗する問題に対応
  # qemu: uncaught target signal 11 (Segmentation fault) - core dumped
  if [ "$(get_os)" == "raspbian" ] && [ ! -f /.dockerenv ]; then
    pushd .

    cd /usr/local
    wget https://dl.google.com/go/go1.13.5.linux-armv6l.tar.gz
    tar -vxzf go1.13.5.linux-armv6l.tar.gz
    ln -s /usr/local/go/bin/go /usr/bin/go
    ln -s /usr/local/go/bin/gofmt /usr/bin/gofmt

    popd
  fi
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
  # TODO: ラズパイdocker環境へgolangインストール
  if [ $(get_os) == "raspbian" ] && [ -f /.dockerenv ]; then
    return
  fi

  mkdir -p $HOME/.go
  # GOPATH, PATH設定は.bashrcでも行っているが、PS1変数未定義などで弾かれる。
  # そのため、go getをここで実行するためにGOPATH, PATHをexport
  export GOPATH=$HOME/.go
  export PATH=$PATH:$GOPATH/bin
  for target in ${GO_GETS[@]}; do
    go get -u $target
  done
  if [ $(get_os) == "ubuntu" ]; then
    for target in ${GO_GETS_UBUNTU[@]}; do
      go get -u $target
    done
  fi
}

deploy_dotfiles() {
  local dot_files=$(ls -a | grep '^\..*' | grep -vE '(^\.$|^\.\.$|\.git$)')
  for file in ${dot_files[@]}; do
    [ ! -e ~/$file ] && ln -s ${DOT_FILES_DIR}$file ~/$file
  done
}

deploy_setting_files() {
  # TODO: remove_str複数ケース対応
  local remove_str
  if [ $(command -v apt) ]; then
    if [ ! -f /.dockerenv ]; then
      remove_str="./deploy/debian/real"
    fi
  fi
  if [[ ! -v remove_str ]]; then
    return
  fi

  remove_str=$(echo $remove_str | sed -e 's/[\/&]/\\&/g')
  deploy_files=$(find ./deploy/debian -type f)
  for file in $deploy_files; do
    local dest=$(echo $file | sed -e "s/$remove_str//")
    cp $file $dest
  done
}

install_vim_plugins() {
  # TODO: ラズパイdocker上で、goが無いためにインストール失敗するので対応
  if [ "$(get_os)" == "raspbian" ] && [ -f /.dockerenv ]; then
    return
  fi

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
  # TODO: ラズパイ実機で日本語入力する際に必要なら設定。dockerでもテキストファイルの日本語が文字化けするので対応
  if [ $(command -v apt) ]; then
    # docker上で日本語入力を可能に
    sed -i "s/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/g" /etc/locale.gen
    locale-gen ja_JP.utf8
  elif [ $(command -v yum) ]; then
    localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
  fi
}

set_timezone() {
  if [ $(date +%Z) = "UTC" ]; then
    if is_valid_exit_code "timedatectl"; then
      timedatectl set-timezone Asia/Tokyo
    else
      if [ $(command -v apt) ]; then
        export DEBIAN_FRONTEND=noninteractive
        apt install -y tzdata
      elif [ $(command -v yum) ]; then
        yum install -y tzdata
      fi
    fi
  fi
}

setup_real_machine() {
  if [ -f /.dockerenv ]; then
    return
  fi

  if [ "$(get_os)" == "ubuntu" ]; then
    # 実機では余計なパッケージが大量に突っ込まれるので削除
    apt-get purge ${UBUNTU_PURGE_PACKAGES[*]}

    apt-get install -y openssh-sever
    curl https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt-get update -y
    sudo apt-get install -y google-chrome-stable
  elif [ "$(get_os)" == "raspbian" ]; then
    # LEDをoffに
    echo "none" >/sys/class/leds/led0/trigger
    echo "none" >/sys/class/leds/led1/trigger
    # 起動時にHDMIを挿入していなくてもHDMIで出力可能に
    sed -i -e "s/#hdmi_force_hotplug=1/hdmi_force_hotplug=1/" /boot/config.txt
    # ssh有効化
    systemctl start ssh
    systemctl enable ssh
  fi
}

# ビープ音無効化等細かい調整
setup_trivial() {
  sed -i -r -e 's/#\s?set bell-style none/set bell-style none/' /etc/inputrc
}

main() {
  SECONDS=0

  if ! $(is_root); then
    echo "Please run with sudo."
    exit 1
  fi
  HOME=$(get_home)

  if $(can_use_command "apt"); then
    add_apt_repository
    apt-get update -y
    install_apt_packages
    install_from_src
  elif $(can_use_command "yum"); then
    setup_yum
    add_rpm_repository
    install_rpm_packages
    install_latest_vim_on_cent
  fi
  go_get

  deploy_dotfiles
  deploy_setting_files
  install_vim_plugins
  set_locale
  set_timezone
  generate_bashrc
  setup_real_machine
  setup_trivial

  echo "$SECONDS 秒で初期化"
  # . .bashrc は、デフォルトの.bashrcに、PS1が設定されていない場合(.sh実行時など)は
  # 実行終了する記載がある場合があるので手動で読み込む
  echo ". ~/.bashrc を実行して下さい"
  echo ".gitconfigのuser, passは必要に応じて修正して下さい"
}

main
