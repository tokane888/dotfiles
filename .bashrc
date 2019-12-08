# personal setting

cat /etc/os-release | grep -Po 'PRETTY_NAME="\K.*(?=")'
cd

# ctrl+s, ctrl+q無効化
if [[ -t 0 ]]; then
  stty stop undef
  stty start undef
fi

# プロンプトの末尾にgit情報及び改行追加
export GIT_PS1_SHOWUPSTREAM=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWDIRTYSTATE=1
if [ -f /usr/share/bash-completion/completions/git ]; then
  source /usr/share/bash-completion/completions/git
elif [ -f /etc/bash_completion.d/git ]; then
  # CentOS対応
  source /etc/bash_completion.d/git
fi
if [ -f /usr/lib/git-core/git-sh-prompt ]; then
  source /usr/lib/git-core/git-sh-prompt
elif [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
  # CentOS対応
  source /usr/share/git-core/contrib/completion/git-prompt.sh
fi
PS1='\[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[0;35m\]$(__git_ps1)\n\[\e[00m\]\$ '
export GOPATH=$HOME/.go
export PATH=$PATH:$GOPATH/bin
# gitのコミットログ文字化け対策
export LESSCHARSET=utf-8
if locale -a | grep ja_JP.utf8; then
  # docker上のubuntuで日本語入力できない対策
  export LC_ALL=ja_JP.UTF-8
fi
export TZ=Asia/Tokyo
