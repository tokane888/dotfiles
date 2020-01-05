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
}
