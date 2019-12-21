#!/bin/bash

set -eux

generate_bashrc() {
  cat .bashrc >>~/.bashrc

  if [ -f /usr/share/bash-completion/completions/git ]; then
    echo "source /usr/share/bash-completion/completions/git" >>~/.bashrc
  elif [ -f /etc/bash_completion.d/git ]; then
    # CentOS対応
    echo "source /etc/bash_completion.d/git" >>~/.bashrc
  fi
  if [ -f /usr/lib/git-core/git-sh-prompt ]; then
    echo "source /usr/lib/git-core/git-sh-prompt" >>~/.bashrc
  elif [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
    # CentOS対応
    echo "source /usr/share/git-core/contrib/completion/git-prompt.sh" >>~/.bashrc
  fi
  # TODO: lsb_release -is だとCentOSで当該コマンドが無いので対応検討
  # cat /etc/os-release | grep -Po '^ID="?\K(.*)(?=")'
  # 上記だとUbuntuのIDが""で囲われていないので取得できない
  # if [ -f /.dockerenv ] && $(lsb_release -is) = "Ubuntu"; then
  if locale -a | grep ja_JP.utf8; then
    # docker上のubuntuで日本語入力できない対策
    echo "export LC_ALL=ja_JP.UTF-8" >>~/.bashrc
  fi
}
