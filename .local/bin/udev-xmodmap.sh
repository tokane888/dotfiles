#!/bin/bash

# Debug: Write immediately (before set -e)
echo "$(date): Script executed by $(whoami)" >> /tmp/udev-xmodmap-debug.log 2>&1

set -euo pipefail

export DISPLAY=":0"
export HOME=/home/tom
export XAUTHORITY="/run/user/1000/gdm/Xauthority"

min_seconds_between_executions=5
date_file="/tmp/last-udev-xmodmap"
now=$(date +%s)

if [[ -f $date_file ]]; then
    prev_ts=$(cat "$date_file")
else
    prev_ts=0
fi

if ((now - prev_ts <= min_seconds_between_executions)); then
    echo "$(date): Too soon, exiting" >> /tmp/udev-xmodmap-debug.log 2>&1
    exit 0
fi

echo "$now" > "$date_file" 2>> /tmp/udev-xmodmap-debug.log
echo "$(date): Timestamp written" >> /tmp/udev-xmodmap-debug.log 2>&1

do_xmodmap() {
    echo "$(date): Starting xmodmap with DISPLAY=$DISPLAY, XAUTHORITY=$XAUTHORITY" >> /tmp/udev-xmodmap-debug.log 2>&1

    for i in {1..5}; do
        if su - tom -c "DISPLAY=:0 XAUTHORITY=/run/user/1000/gdm/Xauthority xmodmap /home/tom/.Xmodmap" 2>&1 | tee -a /tmp/udev-xmodmap-debug.log; then
            echo "$(date): xmodmap succeeded" >> /tmp/udev-xmodmap-debug.log 2>&1
        else
            echo "$(date): xmodmap failed with exit code $?" >> /tmp/udev-xmodmap-debug.log 2>&1
        fi
        # コマンド成功してもkeymapが置き換わらない事があるため複数回実行
        sleep 1
    done
}

do_xmodmap &> "${date_file}.log" &
