# personal setting

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

cat /etc/os-release | grep -Po 'PRETTY_NAME="\K.*(?=")'
cd

export GOPATH=$HOME/.go
export PATH=$PATH:$GOPATH/bin
