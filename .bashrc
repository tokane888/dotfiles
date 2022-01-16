# personal setting

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# TODO: ラズパイでこれがあると何故かscpが失敗するので、調査の上必要なら削除
cat /etc/os-release | grep -Po 'PRETTY_NAME="\K.*(?=")'

# TODO: ubuntu以外の場合はパス修正
export GOPATH=/root/.gvm/pkgsets/go1.17/global
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
export EDITOR=/usr/bin/vim

alias crontab='crontab -i'
alias lal='ls -Al'
alias ll='ls -l'
alias rm='rm' # 別の場所でのalias設定で、ファイル削除時毎回確認されることを抑止
alias ffprobe='ffprobe -hide_banner'

mc() { mkdir -p "$@" && eval cd "\"\$$#\""; }

# tmux newで生成されたsession内で再度tmux newが呼びされれるのを抑止
tmux has-session -t 0
if [ $? != 0 ]; then
  tmux new
fi
