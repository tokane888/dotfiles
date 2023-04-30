# Ubuntu事前設定

## (curlがない場合最初に実行)

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

下記で`-r`オプション付与で開発用実機向けになり、oh-my-zsh等導入される

```
sudo curl -sfL https://raw.githubusercontent.com/tokane888/dotfiles/master/install.sh | sudo bash -
```

## 注意

install_vim_plugins以降のログは標準出力に正常に出力されない。
デバッグの際はdotfiles.logを参照すること
