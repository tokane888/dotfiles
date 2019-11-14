# Preparation(install git)

```
apt update -y
apt install -y git sudo
```
又は
```
yum update -y
yum install -y git sudo
```


# Install

```
mkdir -p ~/.local
cd ~/.local
git clone https://github.com/tokane888/dotfiles.git
cd ~/.local/dotfiles
chmod 777 install.sh
sudo ./install.sh
```
