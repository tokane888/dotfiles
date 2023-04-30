#!/bin/bash
. config.sh
. generate_bashrc.sh

set -eux

REAL_MACHINE=0

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

get_ubuntu_code() {
  echo $(
    . /etc/os-release
    echo $UBUNTU_CODENAME
  )
}

add_apt_repository() {
  if [ "$(get_os)" == "ubuntu" ]; then
    # TODO: ubuntu実機でたまにリポジトリ追加がタイムアウトするケースに対応

    # 実機でminimal installした場合に、universeリポジトリが入らず、
    # apt install時に失敗する場合があるので当該リポジトリ追加
    if ! grep -q universe /etc/apt/sources.list; then
      cat <<EOS >>/etc/apt/sources.list
deb http://jp.archive.ubuntu.com/ubuntu/ $(get_ubuntu_code) universe
deb-src http://jp.archive.ubuntu.com/ubuntu/ $(get_ubuntu_code) universe
deb http://jp.archive.ubuntu.com/ubuntu/ $(get_ubuntu_code)-updates universe
deb-src http://jp.archive.ubuntu.com/ubuntu/ $(get_ubuntu_code)-updates universe
EOS
    fi
    apt-get install -y software-properties-common
    # TODO: ラズパイの場合には当該リポジトリからダウンロード不可。
    #       かつデフォルトのリポジトリから比較的新しいバージョンがインストール可能。
    #       なのでラズパイの場合は当該リポジトリの追加を行わない

    # 複数リポジトリを1コマンドで追加するとエラーになるので1つずつ行う
    for repo in ${APT_REPOS[@]}; do
      add-apt-repository -y $repo
    done
  fi
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

  # npmでnodejsを管理
  npm install n -g
  n stable
  # TODO: nでnpm, nodejsをinstallしたので、aptでinstallしたnpm, nodejsは削除検討
}

install_rpm_packages() {
  yum install -y ${RPM_PACKAGES[*]}
}

install_go_from_src() {
  # TODO: dockerの場合、"go version"でSegmentation faultになり、実行失敗する問題に対応
  # qemu: uncaught target signal 11 (Segmentation fault) - core dumped
  if [ "$(get_os)" == "raspbian" ] && [ ! -f /.dockerenv ]; then
    pushd .

    cd /usr/local
    wget https://go.dev/dl/go1.20.3.linux-armv6l.tar.gz
    tar -vxzf *.tar.gz
    ln -fs /usr/local/go/bin/go /usr/bin/go
    ln -fs /usr/local/go/bin/gofmt /usr/bin/gofmt

    popd
  elif [ "$(get_os)" == "ubuntu" ]; then
    bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)

    set +u
    source ~/.bashrc
    source /root/.gvm/scripts/gvm

    gvm install go1.4 -B
    gvm use go1.4
    # 1.20以降のコンパイルに1.17以上のgoが必要であるため一旦インストール
    gvm install go1.17
    gvm use go1.17
    gvm install go1.20.2
    gvm use go1.20.2 --default

    set -u
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
  [ ! -e /usr/bin/vim ] && ln -fs /root/.local/dotfiles/vim/vim-master/src/vim /usr/bin/vim
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

  mkdir -p ${HOME%/}/.go
  # GOPATH, PATH設定は.bashrcでも行っているが、PS1変数未定義などで弾かれる。
  # そのため、go getをここで実行するためにGOPATH, PATHをexport
  export GOPATH=${HOME%/}/.go
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

pip3_install() {
  pip3 install msgpack pynvim
}

go_install_packages() {
  go install -v github.com/x-motemen/ghq@latest
}

deploy_dotfiles() {
  if [ -v ~/.bashrc ]; then
    mv ~/.bashrc ~/.bashrc.bk
  fi

  local dot_files=$(ls -a | grep '^\..*' | grep -vE '(^\.$|^\.\.$|\.git$|\.ssh$)')
  for file in ${dot_files[@]}; do
    ln -fs ${DOT_FILES_DIR}$file ${HOME%/}/$file
  done

  if [ ! -f ~/.ssh/config ]; then
    cp -r .ssh ~/.ssh
  fi
}

# debian系実機向け設定ファイルデプロイ
deploy_to_real_debian() {
  cp ./deploy/real/debian/keyboard /etc/default/keyboard
}

deploy_setting_files() {
  if [ $(command -v apt) ]; then
    if [ ! -f /.dockerenv ]; then
      deploy_to_real_debian
    fi
  fi
}

install_vim_plugins() {
  # TODO: ラズパイdocker上で、goが無いためにインストール失敗するので対応
  if [ "$(get_os)" == "raspbian" ] && [ -f /.dockerenv ]; then
    return
  fi

  if [ ! -d ${HOME%/}/.vim/bundle/ ]; then
    mkdir -p ${HOME%/}/.vim/bundle/
    git clone https://github.com/VundleVim/Vundle.vim.git ${HOME%/}/.vim/bundle/Vundle.vim
  fi

  vim +PluginInstall +qall < /dev/tty
  #python3 ${HOME%/}/.vim/bundle/YouCompleteMe/install.py --go-completer
  # メッセージがコンソール画面に収まらないと手入力が必要になるのでsilentにバイナリインストール
  vim +'silent :GoInstallBinaries' +qall
}

install_vim_color_scheme() {
  if [ ! -d ${HOME%/}/.vim/colors/ ]; then
    mkdir -p ${HOME%/}/.vim/colors/
    cd ${HOME%/}/.vim/colors/
    wget https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim
  fi
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
    if [ $(command -v apt) ]; then
      apt install -y tzdata
    elif [ $(command -v yum) ]; then
      yum install -y tzdata
    fi

    if is_valid_exit_code "timedatectl"; then
      timedatectl set-timezone Asia/Tokyo
    fi
  fi
}

setup_real_machine() {
  if [ -f /.dockerenv ]; then
    return
  fi

  if [ "$(get_os)" == "ubuntu" ]; then
    # 実機では余計なパッケージが大量に突っ込まれるので削除。
    # ubuntu最小構成では削除対象パッケージが0件になったため削除
    # apt-get purge -y ${UBUNTU_PURGE_PACKAGES[*]}

    apt-get install -y openssh-server
    curl https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt-get update -y
    sudo apt-get install -y google-chrome-stable
    sudo update-alternatives --set editor /usr/bin/vim.basic
    cp tmux-pane-border /usr/local/bin
  elif [ "$(get_os)" == "raspbian" ]; then
    # LEDをoffに
    # TODO: これを/etc/rc.localに書き込まないと再起動後はLED点灯するケース(raspberry PI 3B+)が有ったため対応検討
    echo "none" >/sys/class/leds/led0/trigger
    # zeroではled1ファイルがなくエラーになるため、存在する場合のみ実行
    if [ -f /sys/class/leds/led1/trigger ]; then
      echo "none" >/sys/class/leds/led1/trigger
    fi
    # 起動時にHDMIを挿入していなくてもHDMIで出力可能に
    sed -i -e "s/#hdmi_force_hotplug=1/hdmi_force_hotplug=1/" /boot/config.txt
    # ssh有効化
    systemctl start ssh
    systemctl enable ssh

    # ラズパイzero の場合は下記の2行を/boot/config.txt の末尾に記載し、LED無効化
    # TODO: zeroの判別方法調査
    # dtparam=act_led_trigger=none
    # dtparam=act_led_activelow=on
  fi
}

# ビープ音無効化等細かい調整
setup_trivial() {
  sed -i -r -e 's/#\s?set bell-style none/set bell-style none/' /etc/inputrc
}

cleanup() {
  apt autoremove -y
}

main() {
  SECONDS=0

  if ! $(is_root); then
    echo "Please run with sudo."
    exit 1
  fi
  HOME=$1

  while getopts "r" opt; do
    case $opt in
      r)
        REAL_MACHINE=1
        ;;
    esac
  done

  deploy_dotfiles
  if $(can_use_command "apt"); then
    export DEBIAN_FRONTEND=noninteractive
    add_apt_repository
    apt-get update -y
    install_apt_packages
    install_go_from_src
  elif $(can_use_command "yum"); then
    setup_yum
    add_rpm_repository
    install_rpm_packages
    install_latest_vim_on_cent
  fi
  # dep使わなくなり、現在導入対象外であるためコメントアウト
  # go_get
  pip3_install
  go_install_packages

  deploy_setting_files
  install_vim_color_scheme
  install_vim_plugins
  set_locale
  set_timezone
  generate_bashrc $HOME
  setup_real_machine
  setup_trivial
  cleanup
  if [[ $REAL_MACHINE == 1 ]]; then
    yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  echo "$SECONDS 秒で初期化"
  # . .bashrc は、デフォルトの.bashrcに、PS1が設定されていない場合(.sh実行時など)は
  # 実行終了する記載がある場合があるので手動で読み込む
  echo ". ~/.bashrc を実行して下さい"
  echo ".gitconfigのuser, passは必要に応じて修正して下さい"
}

main $@
