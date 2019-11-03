# personal setting
alias ll='ls -l'
alias crontab='crontab -i'
function mc() { mkdir -p "$@" && eval cd "\"\$$#\""; }

# ctrl+s, ctrl+q無効化
if [[ -t 0 ]]; then
  stty stop undef
  stty start undef
fi
