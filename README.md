# Ubuntu事前設定

## (curlがない場合最初に実行)

* 注意
  * ubuntu実機でupdateを促すダイアログが出ることがあるが下記実行前は無視すること
    * 下記実行前にjpでないrepositoryのパッケージ一覧取得してしまうと、jpとの差異が生じることがある

```
sed -i -e 's/\(deb\|deb-src\) http:\/\/archive.ubuntu.com/\1 http:\/\/jp.archive.ubuntu.com/g' /etc/apt/sources.list
apt update -y;
apt install -y curl sudo;
```

# CentOS事前設定

## (curlがない場合最初に実行)

```
yum install -y curl
```

# ラズパイ事前設定

* /etc/apt/sources.list に下記追記
  * bullseyeの場合(他のディストリビューションの場合、都度調査)
    * deb http://ftp.jaist.ac.jp/raspbian/ bullseye main contrib non-free rpi
* /etc/apt/sources.list に上記以外のリポジトリが記載されていれば削除
* .vimrcのYouCompleteMe pluginがラズパイサポート外なので除外
* .vimrc重すぎるので特にzeroなどの場合必要なら削除

# 共通インストールコマンド

下記で`-r`オプション付与で開発用実機向けになる

```
sudo curl -sfL https://raw.githubusercontent.com/tokane888/dotfiles/master/install.sh | sudo bash -
```

インストール後に、copilot vim pluginについては下記で手動セットアップが必要

```
:Copilot setup
```

## 注意

install_vim_plugins以降のログは標準出力に正常に出力されない。
デバッグの際はdotfiles.logを参照すること
