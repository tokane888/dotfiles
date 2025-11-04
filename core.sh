#!/bin/bash
. config.sh
. generate_bashrc.sh

set -eux

DOT_FILES_DIR="$(cd "$(dirname "$0")" && pwd)"
REAL_MACHINE=0

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
    # apt-get install時に失敗する場合があるので当該リポジトリ追加
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
  # wgetはgithub cli(gh)のインストールにも必要なので先にインストール
  apt-get update -y
  apt-get install -y wget

  wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list >/dev/null

  apt-get update -y
  for package in "${APT_PACKAGES[@]}"; do
    apt-get install -y "$package"
  done
}

install_rpm_packages() {
  for package in "${RPM_PACKAGES[@]}"; do
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

install_npm_packages() {
  # npmでnodejsを管理
  for package in "${NPM_PACKAGES[@]}"; do
    npm install "$package" -g
  done
  claude migrate-installer
  npm install n -g

  n stable
  # TODO: nでnpm, nodejsをinstallしたので、aptでinstallしたnpm, nodejsは削除検討
}

download_binaries() {
  # aws copilot install
  curl -Lo /usr/local/bin/copilot https://github.com/aws/copilot-cli/releases/latest/download/copilot-linux
  chmod +x /usr/local/bin/copilot

  # install git-delta
  # TODO: ubuntu 24.04移行時にapt install git-deltaでapt repositoryからinstallする形に変更
  curl -LO https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_amd64.deb
  apt-get install -y ./git-delta_0.18.2_amd64.deb
}

install_appimages() {
  sudo -u "$SUDO_USER" mkdir -p ~/.local/appimages/cursor

  # TODO: appimageのダウンロード処理追加。Cursor等追加想定
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
  for package in "${PIP3_PACKAGES[@]}"; do
    sudo -u "$SUDO_USER" pip3 install "$package"
  done
}

go_install_packages() {
  go install -v github.com/x-motemen/ghq@latest
  go install -v github.com/air-verse/air@latest
}

deploy_dotfiles() {
  if [ -v "${HOME%/}"/.bashrc ]; then
    mv "${HOME%/}"/.bashrc "${HOME%/}"/.bashrc.bk
  fi
  cp .gitignore "${HOME%/}"/.config/git/ignore
  cp "${DOT_FILES_DIR%/}"/.config/autostart/load-xmodmap.desktop "${HOME%/}"/.config/autostart

  local dot_files=(.*)
  for path in "${dot_files[@]}"; do
    local file=$(basename $path)
    if [[ ! "$file" =~ ^(\.|\.\.|\.git|\.ssh|\.zshrc|\.zsh_aliases_wsl)$ ]]; then
      ln -fs "${DOT_FILES_DIR%/}"/"$file" "${HOME%/}"/"$file"
      if [[ -v "SUDO_USER" ]]; then
        chown "$SUDO_USER":"$SUDO_USER" "${DOT_FILES_DIR%/}"/"$file"
      fi
    fi
  done

  # devcontainerにマウントされることを考慮し、シンボリックリンクは使用しない
  cp .claude/settings.json "${HOME%/}"/.claude/settings.json

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
  locale-gen en_US.UTF-8
  update-locale LANG=en_US.UTF-8 UTF-8
}

set_timezone() {
  if [ "$(date +%Z)" = "UTC" ]; then
    if [ "$(command -v apt)" ]; then
      apt-get install -y tzdata
    elif [ "$(command -v yum)" ]; then
      yum install -y tzdata
    fi

    if is_valid_exit_code "timedatectl"; then
      timedatectl set-timezone Asia/Tokyo
    fi
  fi
}

setup_ubuntu() {
  for package in "${UBUNTU_APT_PACKAGES[@]}"; do
    apt-get install -y "$package"
  done

  update-alternatives --set editor /usr/bin/vim.basic
  cp tmux-pane-border /usr/local/bin

  install_docker

  mkdir -p /opt/ourboard
  cp ./ourboard/docker-compose.yml /opt/ourboard/docker-compose.yml
  cd /opt/ourboard
  docker compose up -d
  cd -

  # taskwarrior - timewarrior連携
  install -D -o "$SUDO_USER" -g "$SUDO_USER" /usr/share/doc/timewarrior/ext/on-modify.timewarrior "${HOME%/}"/.task/hooks/on-modify.timewarrior
  chmod +x "${HOME%/}"/.task/hooks/on-modify.timewarrior

  for package in "${REAL_PIP3_PACKAGES[@]}"; do
    sudo -u "$SUDO_USER" pip3 install "$package"
  done
  # timewarrior集計script
  install -D -o "$SUDO_USER" -g "$SUDO_USER" timewarrior/summarize.py "${HOME%/}"/.timewarrior/extensions

  # taskwarrior-tui install
  curl -L https://github.com/kdheepak/taskwarrior-tui/releases/download/v0.25.4/taskwarrior-tui-x86_64-unknown-linux-gnu.tar.gz | tar zxv --directory=/usr/local/bin

  install_nerd_font
  install_oh-my-zsh

  curl -sSL https://install.python-poetry.org | sudo -u "$SUDO_USER" python3 -
  # poetryのzsh補完設定追加
  mkdir -p "${HOME%/}"/.oh-my-zsh/custom/plugins/poetry
  "${HOME%/}"/.local/bin/poetry completions zsh >"${HOME%/}"/.oh-my-zsh/custom/plugins/poetry/_poetry

  # デフォルトのshellをzshに変更
  su "$NORMAL_USER" -c chsh -s "$(which zsh)"
}

install_real_deb_packages() {
  # localhost:5600でdashboardが見られるが、OS再起動するまでは見えない
  curl -LO https://github.com/ActivityWatch/activitywatch/releases/download/v0.13.1/activitywatch-v0.13.1-linux-x86_64.deb
  dpkg -i activitywatch-v0.13.1-linux-x86_64.deb

  for repo in "${MAIN_PC_APT_REPOS[@]}"; do
    add-apt-repository -y "$repo"
  done

  curl -LO https://www.rescuetime.com/installers/rescuetime_current_amd64.deb
  apt-get install -y ./rescuetime_current_amd64.deb

  echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
  prepare_vscode_install
  curl https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list
  apt-get update -y
  for package in "${MAIN_PC_APT_PACKAGES[@]}"; do
    apt-get install -y "$package"
  done

  usermod -aG wireshark "$SUDO_USER"

  curl -LO https://github.com/obsidianmd/obsidian-releases/releases/download/v1.8.9/obsidian_1.8.9_amd64.deb
  dpkg -i obsidian_1.8.9_amd64.deb
}

setup_autokey() {
  echo "keycode 100 = Hyper_L" > "${HOME%/}"/.Xmodmap
  echo "keycode 102 = Meta_L" > "${HOME%/}"/.Xmodmap
}

prepare_vscode_install() {
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
  install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
  rm -f packages.microsoft.gpg
  # vscode install処理時にapt repositoryへのアクセスにhttpsが使用されるため、apt-transport-httpsの事前installが必要
  apt-get install -y apt-transport-https
}

install_real_pip3_packages() {
  for packages in "${MAIN_PIP3_PACKAGES[@]}"; do
    sudo -u "$SUDO_USER" pip3 install "$packages"
  done
}

install_real_snap_packages() {
  snap refresh
  for package in "${MAIN_PC_SNAP_PACKAGES[@]}"; do
    snap install "$package"
  done
  for package in "${MAIN_PC_SNAP_PACKAGES_CLASSIC[@]}"; do
    snap install "$package" --classic
  done
}

install_docker() {
  apt-get install -y ca-certificates gnupg
  install -m 0755 -d /etc/apt/keyrings
  if [ ! -f "/etc/apt/keyrings/docker.gpg" ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  fi
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    tee /etc/apt/sources.list.d/docker.list >/dev/null
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  usermod -a -G docker "$SUDO_USER"
}

install_nerd_font() {
  # 既にNerd Fontsが存在する場合は終了
  if [ -d "$(su - $NORMAL_USER -c 'ghq root')/github.com/ryanoasis/nerd-fonts" ]; then
    return
  fi

  su "$NORMAL_USER" -c "/home/$NORMAL_USER/go/bin/ghq get --shallow https://github.com/ryanoasis/nerd-fonts"
  local ghq_root
  ghq_root=$(su - $NORMAL_USER -c "/home/$NORMAL_USER/go/bin/ghq root")
  su "$NORMAL_USER" -c "$ghq_root/github.com/ryanoasis/nerd-fonts/install.sh FiraCode"
}

install_oh-my-zsh() {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME%/}"/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-autosuggestions "${HOME%/}"/.oh-my-zsh/custom/plugins/zsh-autosuggestions
}

install_pc_record_service() {
  if [ -f "/dev/video0" ]; then
    mkdir -p "${HOME%/}"/Videos/pc_usage_record
    chown -R $NORMAL_USER:$NORMAL_USER "${HOME%/}"/Videos/pc_usage_record
    cp pc_usage_record.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable --now pc_usage_record.service
  fi
}

install_logkeys() {
  pushd .

  curl -L https://github.com/kernc/logkeys/archive/master.zip -o /tmp/master.zip
  unzip /tmp/master.zip
  cd logkeys-master/
  ./autogen.sh
  cd build
  ../configure
  make
  make install

  popd

  cp logkeys.service /etc/systemd/system/
  systemctl daemon-reload
  systemctl enable --now logkeys.service
  cp logkeys /etc/logrotate.d/logkeys
}

setup_real_ubuntu() {
  install_real_deb_packages

  ln -fs "${DOT_FILES_DIR%/}"/.zshrc "${HOME%/}"/.zshrc
  chsh -s /usr/bin/zsh "$NORMAL_USER"

  setup_autokey

  install_real_pip3_packages
  install_real_snap_packages
  install_pc_record_service
  install_logkeys

  # ubuntu pro向けのsecurityパッケージのインストールを促す広告無効化
  pro config set apt_news=False
}

setup_real_machine() {
  if [ -f /.dockerenv ]; then
    return
  fi

  # WSL上のubuntu及び実機ubuntu向けの処理。
  # 実機ubuntuのみに対する処理はdotfiles_ubuntu.gitで実行
  if [ "$(get_os)" == "ubuntu" ]; then
    setup_ubuntu
    if ((REAL_MACHINE == 1)); then
      setup_real_ubuntu
    fi
    # WSL上のubuntuのみの処理
    if grep -q "WSL" /proc/version; then
      cp wsl.conf /etc/wsl.conf
      ln -fs "${DOT_FILES_DIR%/}"/.zsh_aliases_wsl "${HOME%/}"/.zsh_aliases_wsl
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
  update-alternatives --set editor /usr/bin/vim.basic

  # airpodsのペアリングがデフォルト設定では失敗するのでbluetooth controller mode調整
  CONFIG_FILE="/etc/bluetooth/main.conf"
  ADD_STRING="ControllerMode = bredr"
  if [ -f "$CONFIG_FILE" ]; then
    # /etc/bluetooth/main.conf に ControllerMode = bredr が含まれているか確認
    if ! grep -q "$ADD_STRING" "$CONFIG_FILE"; then
      # 含まれていない場合、末尾に ControllerMode = bredr を追加
      echo "$ADD_STRING" | sudo tee -a "$CONFIG_FILE"
    fi
  fi

  # Ubuntu proの広告popup無効化
  pro config set apt_news=false

  # 1日に1回memory、HDD等の使用量が表示されるので非表示に
  touch /home/"$NORMAL_USER"/.hushlogin

  # awscli実行時に実行結果が自動でlessにパイプされるのを防ぐ設定追加
  aws configure set cli_pager ""
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

  if can_use_command "apt"; then
    export DEBIAN_FRONTEND=noninteractive
    add_apt_repository
    install_apt_packages
    install_go_from_src
  elif can_use_command "yum"; then
    setup_yum
    add_rpm_repository
    install_rpm_packages
    install_latest_vim_on_cent
  fi
  install_npm_packages
  download_binaries
  install_appimages

  deploy_dotfiles

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
    REAL_MACHINE=1
  fi
fi

main "$@"
