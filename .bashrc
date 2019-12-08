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
source /usr/share/bash-completion/completions/git
source /usr/lib/git-core/git-sh-prompt
PS1='\[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[0;35m\]$(__git_ps1)\n\[\e[00m\]\$ '
export GOPATH=$HOME/.go
export PATH=$PATH:$GOPATH/bin
# gitのコミットログ文字化け対策
export LESSCHARSET=utf-8
# docker上で日本語入力できない対策
export LC_ALL=ja_JP.UTF-8
export TZ=Asia/Tokyo
