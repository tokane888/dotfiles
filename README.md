# dotfiles

## Ubuntu事前設定

- 前提
  - ubuntuのデフォルトの言語設定が日本語であること
- curlがない場合下記で追加
  - 注意
    - ubuntu実機でupdateを促すダイアログが出ることがあるが下記実行前は無視すること
      - 下記実行前にjpでないrepositoryのパッケージ一覧取得してしまうと、jpとの差異が生じることがある

  ```shell
  sudo sed -i -e 's/\(deb\|deb-src\) http:\/\/archive.ubuntu.com/\1 http:\/\/jp.archive.ubuntu.com/g' /etc/apt/sources.list
  sudo apt update -y;
  sudo apt install -y curl sudo;
  ```

## CentOS事前設定

- curlがない場合

  ```shell
  sudo yum install -y curl
  ```

## ラズパイ事前設定

- /etc/apt/sources.list に下記追記
  - bullseyeの場合(他のディストリビューションの場合、都度調査)
    - deb <http://ftp.jaist.ac.jp/raspbian/> bullseye main contrib non-free rpi
- /etc/apt/sources.list に上記以外のリポジトリが記載されていれば削除
- .vimrc重すぎるので特にzeroなどの場合必要なら削除

## 共通インストールコマンド

下記で`-r`オプション付与で開発用実機向けになる

```shell
curl -LO https://raw.githubusercontent.com/tokane888/dotfiles/master/install.sh
sudo bash -x install.sh
```

インストール後に、copilot vim pluginについては下記で手動セットアップが必要

```shell
:Copilot setup
```

## Ubuntu実機での追加設定

- gsettings関連コマンドはsudoで実行すると終了コードは0になるもののwarnを出してfailするので、別途下記で実行
  - 最初に確認ダイアログが表示される

    ```shell
    ./real_ubuntu.sh
    ```

  - インストール後に画面右上から適宜Time++関連設定調整

- autokeyがwaylandに対応するまで当面下記手順でx11を使用
  - 手順
    - ログアウト
    - ユーザー名押下
    - 右下の歯車からX11選択
  - waylandだとterminal上でautokeyが機能しない場合等があるため

- copyQ起動し、下記設定
  - file => preferences
  - "Autostart"有効化
  - Shortcuts => Global => Show/hide main windowにmeta+ctrl+i辺りを割当
  - Shortcuts => Application => Save itemにctrl+s割当
  - Shortcuts => Application => exportへのctrl+s割当解除
  - "ok"
  - CopyQを再度起動し、Tabs => New tabから適宜tab追加

- 無変換+ctrl+dでDownloadディレクトリ開くショートカット追加
  - win => settings => Keyboard => Custom Shortcuts
  - "nautilus /home/tom/Downloads"
    - ユーザー名は適宜調整
      - エラーになるので必ず絶対パス指定
  - TODO: 設定backup可能か検討
    - <https://askubuntu.com/questions/682513/how-to-backup-restore-system-custom-keyboard-shortcuts>

- 他注意点
  - 少なくとも下記の変更は再起動するまで反映されない
    - ダウンロードディレクトリ等の名前の英語への変更されない
    - defaultのshellのzshへの変更

### Ubuntu実機での現時点での制約

- OSの無変換+ctrl+dショートカットは手動で再設定が必要
- tmux上でのコピーは下記で可能
  - shift押下
    - shift押下せずに範囲選択も可能だが、コピーが失敗する
  - 文字列範囲選択
  - ctrl+shift+c

## 注意

install_vim_plugins以降のログは標準出力に正常に出力されない。
デバッグの際はdotfiles.logを参照すること
