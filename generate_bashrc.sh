#!/bin/bash

set -eux

generate_bashrc() {
  local home=$1

  # OS別設定
  echo "# git入力補完" >>$home/.bashrc
  if [ -f /usr/share/bash-completion/completions/git ]; then
    echo "source /usr/share/bash-completion/completions/git" >>$home/.bashrc
  elif [ -f /etc/bash_completion.d/git ]; then
    echo "source /etc/bash_completion.d/git" >>$home/.bashrc
  fi
  if [ -f /usr/lib/git-core/git-sh-prompt ]; then
    echo "source /usr/lib/git-core/git-sh-prompt" >>$home/.bashrc
  elif [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
    echo "source /usr/share/git-core/contrib/completion/git-prompt.sh" >>$home/.bashrc
  fi

  if [ -f /etc/bash_completion ]; then
    echo "source /etc/bash_completion" >>$home/.bashrc
  fi
}
