# personal setting

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

cat /etc/os-release | grep -Po 'PRETTY_NAME="\K.*(?=")'
cd

export GOPATH=$HOME/.go
export PATH=$PATH:$GOPATH/bin

# ctrl+s, ctrl+q無効化
if [[ -t 0 ]]; then
  stty stop undef
  stty start undef
fi

# gitのコミットログ文字化け対策
export LESSCHARSET=utf-8
export TZ=Asia/Tokyo

# プロンプトの末尾にgit情報及び改行追加
export GIT_PS1_SHOWUPSTREAM=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWDIRTYSTATE=1
PS1='\[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[0;35m\]$(__git_ps1)\n\[\e[00m\]\$ '

export LC_ALL=ja_JP.UTF-8
