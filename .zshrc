# rm *で確認を求める機能を無効化
setopt RM_STAR_SILENT

# prompt表示にstarshipを使用するよう設定
eval "$(starship init zsh)"

# ctrl-]で指定gitのディレクトリへ移動
function peco-src () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-src
bindkey '^]' peco-src

# git: ctrl-x bでブランチ選択
function peco-branch () {
    local branch=$(git branch -a | peco | tr -d ' ' | tr -d '*')
    if [ -n "$branch" ]; then
      if [ -n "$LBUFFER" ]; then
        local new_left="${LBUFFER%\ } $branch"
      else
        local new_left="$branch"
      fi
      BUFFER=${new_left}${RBUFFER}
      CURSOR=${#new_left}
    fi
}
zle -N peco-branch
bindkey '^xb' peco-branch # C-x b でブランチ選択

eval "$(starship init zsh)"

. ~/.zshrc_cmd/todoist_toggl.sh

if [ -f ~/.zsh_aliases ]; then
    source ~/.zsh_aliases
fi
if [ -f ~/.zsh_aliases_local ]; then
    source ~/.zsh_aliases_local
fi