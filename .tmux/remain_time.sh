#!/bin/bash

# 現在の日時を取得
current_time=$(date +"%H:%M")

# 目標の時刻を設定
target_time="18:30"

# 現在の日時と目標の時刻をUnixタイムスタンプに変換
current_timestamp=$(date -d "$current_time" +%s)
target_timestamp=$(date -d "$target_time" +%s)

# 残り時間（秒）を計算
remaining_seconds=$((target_timestamp - current_timestamp))

# 残り時間を05:06形式にフォーマット
remaining_hours=$((remaining_seconds / 3600))
remaining_minutes=$((remaining_seconds % 3600 / 60))

# 残り時間が負の場合何も表示しない
if [ $remaining_minutes -lt 0 ]; then
    echo ""
else
    # ゼロパディングして05:06形式で残り時間を表示
    printf "[%02d:%02d]" "$remaining_hours" "$remaining_minutes"
fi
