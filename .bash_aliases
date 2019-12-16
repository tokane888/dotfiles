alias crontab='crontab -i'
alias lal='ls -al'
alias ll='ls -l'
alias rm='rm' # 別の箇所のaliasで-i設定を付与され、消去の際に確認されるのを抑止

mc() { mkdir -p "$@" && eval cd "\"\$$#\""; }
