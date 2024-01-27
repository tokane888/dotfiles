#!/bin/bash

set -euxo pipefail

# 日本語入力設定
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'jp'), ('ibus', 'mozc-jp')]"
# super + lによるlock無効化
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "[]"
# ctrl + . => 下線付きの_ 無効化
gsettings set org.freedesktop.ibus.panel.emoji hotkey "[]"
# win + d => desktop表示 無効化
gsettings set org.gnome.desktop.wm.keybindings show-desktop "[]"
