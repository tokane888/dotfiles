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
  * busterの場合(他のディストリビューションの場合、都度調査)
    * deb http://ftp.jaist.ac.jp/raspbian/ buster main contrib non-free rpi
* /etc/apt/sources.list に上記以外のリポジトリが記載されていれば削除
* .vimrcのYouCompleteMe pluginがラズパイサポート外なので除外
* .vimrc重すぎるので特にzeroなどの場合必要なら削除

# 共通インストールコマンド

```
sudo curl -sfL https://raw.githubusercontent.com/tokane888/dotfiles/master/install.sh | sudo bash -
```
