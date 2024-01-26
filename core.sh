#!/bin/bash
. config.sh
. generate_bashrc.sh

set -eux

MAIN_MACHINE=0

is_root() {
  [ ${EUID:-${UID}} = 0 ]
}

can_use_command() {
  local command=$1

  [ -x "$(command -v "$command")" ]
}

get_os() {
  echo "$(
    . /etc/os-release
    echo $ID
  )"
}

get_ubuntu_code() {
  echo "$(
    . /etc/os-release
    echo "$UBUNTU_CODENAME"
  )"
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
    for repo in "${APT_REPOS[@]}"; do
      add-apt-repository -y "$repo"
    done
  fi
}

add_rpm_repository() {
  for repo in "${RPM_REPOS[@]}"; do
    yum install -y "$repo"
  done
}

install_apt_packages() {
  for package in "${APT_PACKAGES[@]}"
  do
    apt-get install -y "$package"
  done

  # npmでnodejsを管理
  npm install n -g
  n stable
  # TODO: nでnpm, nodejsをinstallしたので、aptでinstallしたnpm, nodejsは削除検討
}

install_rpm_packages() {
  for package in "${RPM_PACKAGES[@]}"
  do
    yum install -y "$packages"
  done
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
    snap install --classic go
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
  if can_use_command "yum"; then
    # dockerのyum設定から、manpageを取得しない設定削除
    sed -i s/tsflags=nodocs//g /etc/yum.conf
  fi
}

pip3_install() {
  for package in "${PIP3_PACKAGES[@]}"
  do
    pip3 install "$package"
  done
}

go_install_packages() {
  go install -v github.com/x-motemen/ghq@latest
}

deploy_dotfiles() {
  if [ -v "${HOME%/}"/.bashrc ]; then
    mv "${HOME%/}"/.bashrc "${HOME%/}"/.bashrc.bk
  fi

  local dot_files=(.*)
  for path in "${dot_files[@]}"; do
    local file=$(basename $path)
    if [[ ! "$file" =~ ^(\.|\.\.|\.git|\.ssh)$ ]]; then
      ln -fs "${DOT_FILES_DIR}""$file" "${HOME%/}"/"$file"
      if [[ -v "SUDO_USER" ]]; then
        chown "$SUDO_USER":"$SUDO_USER" "${DOT_FILES_DIR}""$file"
      fi
    fi
  done

  if [ ! -f "${HOME%/}"/.ssh/config ]; then
    cp -r .ssh "${HOME%/}"/.ssh
  fi
}

# debian系実機向け設定ファイルデプロイ
deploy_to_real_debian() {
  cp ./deploy/real/debian/keyboard /etc/default/keyboard
}

deploy_setting_files() {
  if command -v apt; then
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

  if [ ! -d "${HOME%/}"/.vim/bundle/ ]; then
    mkdir -p "${HOME%/}"/.vim/bundle/
    git clone https://github.com/VundleVim/Vundle.vim.git "${HOME%/}"/.vim/bundle/Vundle.vim
  fi

  vim +PluginInstall +qall </dev/tty
  #python3 "${HOME%/}"/.vim/bundle/YouCompleteMe/install.py --go-completer
  # メッセージがコンソール画面に収まらないと手入力が必要になるのでsilentにバイナリインストール
  vim +'silent :GoInstallBinaries' +qall
}

install_vim_color_scheme() {
  if [ ! -d "${HOME%/}"/.vim/colors/ ]; then
    pushd .

    mkdir -p "${HOME%/}"/.vim/colors/
    cd "${HOME%/}"/.vim/colors/
    wget https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim

    popd
  fi
}

is_valid_exit_code() {
  local cmd=$1
  $cmd
}

set_locale() {
  # TODO: ラズパイ実機で日本語入力する際に必要なら設定。dockerでもテキストファイルの日本語が文字化けするので対応
  if [ "$(command -v apt)" ]; then
    # docker上で日本語入力を可能に
    sed -i "s/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/g" /etc/locale.gen
    locale-gen ja_JP.utf8
  elif [ "$(command -v yum)" ]; then
    localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
  fi
}

set_timezone() {
  if [ "$(date +%Z)" = "UTC" ]; then
    if [ "$(command -v apt)" ]; then
      apt install -y tzdata
    elif [ "$(command -v yum)" ]; then
      yum install -y tzdata
    fi

    if is_valid_exit_code "timedatectl"; then
      timedatectl set-timezone Asia/Tokyo
    fi
  fi
}

setup_real_ubuntu() {
  apt-get install -y openssh-server sshpass
  sudo update-alternatives --set editor /usr/bin/vim.basic
  cp tmux-pane-border /usr/local/bin

  apt-get install -y ca-certificates curl gnupg
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # plantuml向け
  apt-get install -y default-jre graphviz fonts-ipafont

  mkdir -p /opt/ourboard
  cp ./ourboard/docker-compose.yml /opt/ourboard/docker-compose.yml
  cd /opt/ourboard
  docker compose up -d
  cd -

  apt-get install -y taskwarrior timewarrior
  # TODO: taskwarrior-tuiのインストール処理が簡略化されたら追記
  yes | task
  yes | timew

  # taskwarrior - timewarrior連携
  cp /usr/share/doc/timewarrior/ext/on-modify.timewarrior "${HOME%/}"/.task/hooks/
  chmod +x "${HOME%/}"/.task/hooks/on-modify.timewarrior

  for package in "${REAL_PIP3_PACKAGES[@]}"
  do
    pip3 install "$package"
  done
  # timewarrior集計script
  cp timewarrior/summarize.py "${HOME%/}"/.timewarrior/extensions

  install_starship_shell_prompt
}

install_main_deb_packages() {
  # localhost:5600でdashboardが見られるが、OS再起動するまでは見えない
  curl -LO https://github.com/ActivityWatch/activitywatch/releases/download/v0.12.2/activitywatch-v0.12.2-linux-x86_64.deb
  dpkg -i activitywatch-v0.12.2-linux-x86_64.deb

  for repo in "${MAIN_PC_APT_REPOS[@]}"
  do
    add-apt-repository -y "$repo"
  done

  echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
  DEBIAN_FRONTEND=noninteractive apt-get -y install wireshark
  prepare_vscode_install

  apt-get update -y
  apt-get install -y "${MAIN_PC_APT_PACKAGES[*]}"

  curl https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
  sudo apt-get update -y
  sudo apt-get install -y google-chrome-stable

  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  setup_autokey

  gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'jp'), ('ibus', 'mozc-jp')]"
  # super + lによるlock無効化
  gsettings set org.gnome.desktop.lockdown disable-lock-screen true
  # ctrl + l => 下線付きの_ 無効化
  gsettings set org.freedesktop.ibus.panel.emoji hotkey "[]"
  # win + d => desktop表示 無効化
  gsettings set org.gnome.desktop.wm.keybindings show-desktop "[]"
}

setup_autokey() {
  mkdir bk
  cp /usr/share/X11/xkb/symbols/inet bk/
  sed -i 's/Henkan/Hyper_L/' /usr/share/X11/xkb/symbols/inet
  sed -i 's/Muhenkan/Meta_L/' /usr/share/X11/xkb/symbols/inet
}

prepare_vscode_install() {
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
  rm -f packages.microsoft.gpg
  apt-get install -y apt-transport-https
  apt-get update -y
}

install_main_snap_packages() {
  snap refresh
  snap install "${MAIN_PC_SNAP_PACKAGES[*]}"
}

install_starship_shell_prompt() {
  pushd .
  cd $HOME
  mkdir -p ghq/github.com/ryanoasis/nerd-fonts
  chown -R $NORMAL_USER:$NORMAL_USER ghq
  cd $HOME/ghq/github.com/ryanoasis/nerd-fonts
  sudo su $NORMAL_USER -c "git clone https://github.com/ryanoasis/nerd-fonts.git $HOME/ghq/github.com/ryanoasis/nerd-fonts/"
  sudo su $NORMAL_USER -c "$HOME/ghq/github.com/ryanoasis/nerd-fonts/install.sh FiraCode"
  popd

  snap install starship --edge

  mkdir -p "${HOME%/}"/.config/
  cp config/startship.toml "${HOME%/}"/.config/
}

install_oh-my-zsh_plugin() {
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME%/}"/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-autosuggestions "${HOME%/}"/.oh-my-zsh/custom/plugins/zsh-autosuggestions
  ## TODO: .zshrcのpluginにgit zsh-syntax-highlighting zsh-autosuggestions追記
}

install_pc_record_service() {
  cp pc_usage_record.service /lib/systemd/system/
  systemctl daemon-reload
  systemctl enable --now pc_usage_record.service
}

setup_keymap() {
  sed -i 's/Muhenka/Meta_L/' /usr/share/X11/xkb/symbols/inet
  sed -i 's/Henkan/Hyper_L/' /usr/share/X11/xkb/symbols/inet
}

setup_main_ubuntu() {
  setup_keymap
  install_main_deb_packages
  install_main_snap_packages
  install_starship_shell_prompt
  install_pc_record_service
}

setup_real_machine() {
  if [ -f /.dockerenv ]; then
    return
  fi

  # WSL上のubuntu及び実機ubuntu向けの処理。
  # 実機ubuntuのみに対する処理はdotfiles_ubuntu.gitで実行
  if [ "$(get_os)" == "ubuntu" ]; then
    setup_real_ubuntu
    if (( MAIN_MACHINE == 1 )); then
      setup_main_ubuntu
    fi
    # WSL上のubuntuのみの処理
    if grep -q "WSL" /proc/version; then
      cp wsl.conf /etc/wsl.conf
    fi
  elif [ "$(get_os)" == "raspbian" ]; then
    # TODO: リンク先の方法でlanも含めたLED消去対応
    #     https://smarthomescene.com/guides/how-to-disable-leds-on-raspberry-pi-3b-4b/

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

setup_trivial() {
  # terminalでのビープ音無効化
  sed -i -r -e 's/#\s?set bell-style none/set bell-style none/' /etc/inputrc
  # visudoのエディタをvimに
  sudo update-alternatives --set editor /usr/bin/vim.basic
}

cleanup() {
  apt autoremove -y
}

main() {
  SECONDS=0

  if ! is_root; then
    echo "Please run with sudo."
    exit 1
  fi
  HOME=$1
  NORMAL_USER=$(basename $HOME)

  deploy_dotfiles
  if can_use_command "apt"; then
    export DEBIAN_FRONTEND=noninteractive
    add_apt_repository
    apt-get update -y
    install_apt_packages
    install_go_from_src
  elif can_use_command "yum"; then
    setup_yum
    add_rpm_repository
    install_rpm_packages
    install_latest_vim_on_cent
  fi
  pip3_install
  go_install_packages

  deploy_setting_files
  install_vim_color_scheme
  install_vim_plugins
  set_locale
  set_timezone
  generate_bashrc "$HOME"
  setup_real_machine
  setup_trivial
  cleanup
  chown -R $NORMAL_USER:$NORMAL_USER "$HOME"

  echo "$SECONDS 秒で初期化"
  # . .bashrc は、デフォルトの.bashrcに、PS1が設定されていない場合(.sh実行時など)は
  # 実行終了する記載がある場合があるので手動で読み込む
  echo ". ~/.bashrc を実行して下さい"
  echo ".gitconfigのuser, passは必要に応じて修正して下さい"
}

if (($# >= 2)); then
  if [[ "$2" == "-r" ]]; then
    MAIN_MACHINE=1
  fi
fi

main "$@"
