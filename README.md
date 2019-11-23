# Ubuntuへインストール

```
apt update -y
apt install -y git sudo
mkdir -p ~/.local
cd ~/.local
git clone https://github.com/tokane888/dotfiles.git
cd ~/.local/dotfiles
chmod 777 install.sh
sudo ./install.sh
```
