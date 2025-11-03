#!/bin/bash

set -euxo pipefail

# 日本語入力設定
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'jp'), ('ibus', 'mozc-jp')]"
# ctrl + . => 下線付きの_ 無効化
gsettings set org.freedesktop.ibus.panel.emoji hotkey "[]"
# win + d => desktop表示 無効化
gsettings set org.gnome.desktop.wm.keybindings show-desktop "[]"
# 変換 + f => window最大化(変換+jは何かと競合したのか設定出来ず)
gsettings set org.gnome.desktop.wm.keybindings maximize "['<Hyper>f']"
