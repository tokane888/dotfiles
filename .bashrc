# personal setting
alias ll='ls -l'
alias lal='ls -al'
alias crontab='crontab -i'
function mc() { mkdir -p "$@" && eval cd "\"\$$#\""; }

cat /etc/os-release | grep -Po 'PRETTY_NAME="\K.*(?=")'
cd

# ctrl+s, ctrl+q無効化
if [[ -t 0 ]]; then
  stty stop undef
  stty start undef
fi
