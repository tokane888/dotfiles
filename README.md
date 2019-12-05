# Ubuntuへインストール

```
command -v sudo || (apt update -y; apt install -y git sudo)
command -v git || (sudo apt update -y; sudo apt install -y git)
mkdir -p ~/.local
cd ~/.local
git clone https://github.com/tokane888/dotfiles.git
cd ~/.local/dotfiles
sudo ./install.sh
```

# Ubuntuへインストール（pushも行う場合）

* localのid_rsaを新環境の~/.ssh/id_rsaへコピー
* `chmod 0600 id_rsa`

```
command -v git || (sudo apt update -y; sudo apt install git)
mkdir -p ~/.local
cd ~/.local
git clone git@github.com:tokane888/dotfiles.git
cd ~/.local/dotfiles
sudo ./install.sh
```
