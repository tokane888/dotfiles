# Ubuntu事前設定

## (curlがない場合最初に実行)

```
sed -i -e 's/\(deb\|deb-src\) http:\/\/archive.ubuntu.com/\1 http:\/\/jp.archive.ubuntu.com/g' /etc/apt/sources.list
apt update -y;
apt install -y curl;
```

# CentOS事前設定

## (curlがない場合最初に実行)

```
yum install -y curl
```

# 共通インストールコマンド

```
sudo curl -sfL https://raw.githubusercontent.com/tokane888/dotfiles/master/install.sh | sudo sh -
```
