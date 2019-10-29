# personal setting
alias ll='ls -l'
alias crontab='crontab -i'
function mc () { mkdir -p "$@" && eval cd "\"\$$#\""; }

if [[ -t 0 ]]; then
  stty stop undef
  stty start undef
fi
