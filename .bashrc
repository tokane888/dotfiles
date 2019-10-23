# personal setting
alias ll='ls -l'
alias crontab='crontab -i'
function mc () { mkdir -p "$@" && eval cd "\"\$$#\""; }