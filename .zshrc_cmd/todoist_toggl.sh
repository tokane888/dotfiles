#!/bin/bash

## todoist CLI + toggl CLI連携し、ctrl+x => t => sでtodoistの今日の指定タスクをtogglで計測開始
function toggl-start-todoist () {
    local selected_item_id=$(todoist list --filter today -p | peco | cut -d ' ' -f 1)
    if [ ! -n "$selected_item_id" ]; then
        return 0
    fi
    local selected_item_content=$(todoist --csv show ${selected_item_id} | grep Content | cut -d',' -f2- | sed s/\"//g)
    local selected_item_project=$(todoist --csv show ${selected_item_id} | grep Project | cut -d',' -f2- | sed 's/^#//')
    if [ -n "$selected_item_content" ]; then
        BUFFER="toggl start \"${selected_item_content}\" --project \"${selected_item_project}\""
        CURSOR=$#BUFFER
        zle accept-line
    fi
}
zle -N toggl-start-todoist
bindkey '^xts' toggl-start-todoist

# todoist find project
function peco-todoist-project () {
    local SELECTED_PROJECT="$(todoist projects | peco | head -n1 | cut -d ' ' -f 1)"
    if [ -n "$SELECTED_PROJECT" ]; then
        if [ -n "$LBUFFER" ]; then
            local new_left="${LBUFFER%\ } $SELECTED_PROJECT"
        else
            local new_left="$SELECTED_PROJECT"
        fi
        BUFFER=${new_left}${RBUFFER}
        CURSOR=${#new_left}
    fi
}
zle -N peco-todoist-project
bindkey "^xtp" peco-todoist-project

# todoist find labels
function peco-todoist-labels () {
    local SELECTED_LABELS="$(todoist labels | peco | cut -d ' ' -f 1 | tr '\n' ',' | sed -e 's/,$//')"
    if [ -n "$SELECTED_LABELS" ]; then
        if [ -n "$LBUFFER" ]; then
            local new_left="${LBUFFER%\ } $SELECTED_LABELS"
        else
            local new_left="$SELECTED_LABELS"
        fi
        BUFFER=${new_left}${RBUFFER}
        CURSOR=${#new_left}
    fi
}
zle -N peco-todoist-labels
bindkey "^xtl" peco-todoist-labels

# todoist close
function peco-todoist-close() {
    local SELECTED_ITEMS="$(todoist list --filter today -p  | peco | cut -d ' ' -f 1 | tr '\n' ' ')"
    if [ -n "$SELECTED_ITEMS" ]; then
        BUFFER="todoist close $(echo "$SELECTED_ITEMS" | tr '\n' ' ')"
        CURSOR=$#BUFFER
    fi
    zle accept-line
}
zle -N peco-todoist-close
bindkey "^xtc" peco-todoist-close

# 補完効かせたいが、repo消えてる。対応優先度低め
#PROG=todoist source "/home/tom/ghq/github.com/urfave/cli/autocomplete/zsh_autocomplete"
