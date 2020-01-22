# Ubuntuへインストール

```
sed -i -e 's/\(deb\|deb-src\) http:\/\/archive.ubuntu.com/\1 http:\/\/jp.archive.ubuntu.com/g' /etc/apt/sources.list
apt update -y;
apt install -y git sudo;
mkdir -p ~/.local
cd ~/.local
git clone https://github.com/tokane888/dotfiles.git
cd ~/.local/dotfiles
sudo ./install.sh
```

# CentOSへインストール

```
yum remove -y git
yum install -y https://centos7.iuscommunity.org/ius-release.rpm
yum install -y git2u sudo;
mkdir -p ~/.local
cd ~/.local
git clone https://github.com/tokane888/dotfiles.git
cd ~/.local/dotfiles
sudo ./install.sh
```
