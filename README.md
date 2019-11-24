# Ubuntu実機へインストール

```
command -v git || (sudo apt update -y; sudo apt install git)
mkdir -p ~/.local
cd ~/.local
git clone https://github.com/tokane888/dotfiles.git
cd ~/.local/dotfiles
sudo ./install.sh
```

# Ubuntu実機へインストール（pushも行う場合）

* localのid_rsaを新環境の~/.ssh/id_rsaへコピー
* `chmod 0600 id_rsa`

```
command -v git || (sudo apt update -y; sudo apt install git)
mkdir -p ~/.local
cd ~/.local
yes yes | git clone git@github.com:tokane888/dotfiles.git
cd ~/.local/dotfiles
sudo ./install.sh
```
