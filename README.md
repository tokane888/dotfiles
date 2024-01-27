# dotfiles

## Ubuntu事前設定

- 前提
  - ubuntuのデフォルトの言語設定が日本語であること
- curlがない場合下記で追加
  - 注意
    - ubuntu実機でupdateを促すダイアログが出ることがあるが下記実行前は無視すること
      - 下記実行前にjpでないrepositoryのパッケージ一覧取得してしまうと、jpとの差異が生じることがある

  ```shell
  sed -i -e 's/\(deb\|deb-src\) http:\/\/archive.ubuntu.com/\1 http:\/\/jp.archive.ubuntu.com/g' /etc/apt/sources.list
  apt update -y;
  apt install -y curl sudo;
  ```

## CentOS事前設定

- curlがない場合

  ```shell
  yum install -y curl
  ```

## ラズパイ事前設定

- /etc/apt/sources.list に下記追記
  - bullseyeの場合(他のディストリビューションの場合、都度調査)
    - deb <http://ftp.jaist.ac.jp/raspbian/> bullseye main contrib non-free rpi
- /etc/apt/sources.list に上記以外のリポジトリが記載されていれば削除
- .vimrcのYouCompleteMe pluginがラズパイサポート外なので除外
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

  ```shell
  ./real_ubuntu.sh
  ```

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

- 他注意点
  - 少なくとも下記の変更は再起動するまで反映されない
    - ダウンロードディレクトリ等の名前の英語への変更されない
    - defaultのshellのzshへの変更

### Ubuntu実機での現時点での制約

- vscodeのterminal上でnerd font(gitグラフアイコン等)が正常に表示されない
  - <https://github.com/ryanoasis/nerd-fonts/issues/831>
  - あまり影響ないのでvscode updateで解消するのを待つ

## 注意

install_vim_plugins以降のログは標準出力に正常に出力されない。
デバッグの際はdotfiles.logを参照すること
