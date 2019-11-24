# Ubuntu実機へインストール

```
command -v git || (sudo apt update -y; sudo apt install git)
mkdir -p ~/.local
cd ~/.local
git clone https://github.com/tokane888/dotfiles.git
cd ~/.local/dotfiles
sudo ./install.sh
```
