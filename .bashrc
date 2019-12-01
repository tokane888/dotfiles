# personal setting

cat /etc/os-release | grep -Po 'PRETTY_NAME="\K.*(?=")'
cd

# ctrl+s, ctrl+q無効化
if [[ -t 0 ]]; then
  stty stop undef
  stty start undef
fi

# プロンプトの末尾に改行追加
PS1='\[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[0;35m\]$(__git_ps1)\n\[\e[00m\]\$ '
export GOPATH=$HOME/.go
export PATH=$PATH:$GOPATH/bin
export LESSCHARSET=utf-8
