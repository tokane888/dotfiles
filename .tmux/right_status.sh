#!/bin/bash

# togglで進行中のタスクを表示
function toggl_now() {
  local tgn_time=$(toggl now | grep Duration | cut -d ' ' -f 2)
  local tgn_dsc=$(toggl now | head -1 | grep -oP '.*(?= #.*)')
  local short_tgn_dsc=$(if [ $(echo $tgn_dsc | wc -m) -lt 20 ]; then echo $tgn_dsc; else echo "${tgn_dsc}.."; fi)
  if [ ! -n "$tgn_time" ]; then
      echo ""
  else
      echo "[$tgn_time $short_tgn_dsc]"
  fi
}

toggl_now
