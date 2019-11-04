alias crontab='crontab -i'
alias lal='ls -al'
alias ll='ls -l'

function mc() { mkdir -p "$@" && eval cd "\"\$$#\""; }
