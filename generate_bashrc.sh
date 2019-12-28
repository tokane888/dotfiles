#!/bin/bash

set -eux

generate_bashrc() {
  cat .bashrc >>~/.bashrc

  # OS別設定
  echo "# git入力補完" >>~/.bashrc
  if [ -f /usr/share/bash-completion/completions/git ]; then
    echo "source /usr/share/bash-completion/completions/git" >>~/.bashrc
  elif [ -f /etc/bash_completion.d/git ]; then
    echo "source /etc/bash_completion.d/git" >>~/.bashrc
  fi
  if [ -f /usr/lib/git-core/git-sh-prompt ]; then
    echo "source /usr/lib/git-core/git-sh-prompt" >>~/.bashrc
  elif [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
    echo "source /usr/share/git-core/contrib/completion/git-prompt.sh" >>~/.bashrc
  fi

  if [ -f /etc/bash_completion ]; then
    echo "source /etc/bash_completion" >>~/.bashrc
  else
    # CentOSではmakeの補完が機能しなかったため追加
    complete -W "\`grep -oE '^[a-zA-Z0-9_.-]+:([^=]|$)' ?akefile | sed 's/[^a-zA-Z0-9_.-]*$//'\`" make
  fi

  # TODO: lsb_release -is だとCentOSで当該コマンドが無いので対応検討
  # cat /etc/os-release | grep -Po '^ID="?\K(.*)(?=")'
  # 上記だとUbuntuのIDが""で囲われていないので取得できない
  # if [ -f /.dockerenv ] && $(lsb_release -is) = "Ubuntu"; then
  if locale -a | grep ja_JP.utf8; then
    echo "# docker上のubuntuで日本語入力できない対策" >>~/.bashrc
    echo "export LC_ALL=ja_JP.UTF-8" >>~/.bashrc
  elif [ -f /.dockerenv ] && [ $(command -v yum) ]; then
    echo "# docker上のcentOS用日本語設定" >>~/.bashrc
    echo "export LANG=ja_JP.UTF-8" >>~/.bashrc
    echo "export LANGUAGE=ja_JP:ja" >>~/.bashrc
    echo "export LC_ALL=ja_JP.UTF-8" >>~/.bashrc
  fi
}
