# personal setting

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

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

export EDITOR=/usr/bin/vim

alias crontab='crontab -i'
alias lal='ls -Al'
alias ll='ls -l'
alias rm='rm' # 別の場所でのalias設定で、ファイル削除時毎回確認されることを抑止
alias ffprobe='ffprobe -hide_banner'
alias gipu='git add . && git commit -m "追記" && git push'

mc() { mkdir -p "$@" && eval cd "\"\$$#\""; }

alias clip.exe=/mnt/c/Windows/System32/clip.exe
alias ffplay.exe=/mnt/c/ProgramData/chocolatey/bin/ffplay.exe

# WSL2向けvagrant設定
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox:/mnt/c/Windows/System32"
export PATH="$PATH:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"
