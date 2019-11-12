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
mkdir -p ~/.config
cd ~/.config
git clone https://github.com/tokane888/dotfiles.git
cd ~/.config/dotfiles
chmod 777 install.sh
sudo ./install.sh
```
