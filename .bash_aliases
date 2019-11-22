alias crontab='crontab -i'
alias lal='ls -al'
alias ll='ls -l'

mc() { mkdir -p "$@" && eval cd "\"\$$#\""; }
