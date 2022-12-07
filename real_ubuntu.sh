#!/bin/bash

set -euxo pipefail

DEB_PACKAGES=(
  nmap
  snapd
  xclip
)

install_vscode() {
  curl -L https://go.microsoft.com/fwlink/?LinkID=760868 -o vscode.deb
  apt-get install -y ./vscode.deb
  mkdir -p /root/.config/Code
}

install_deb_packages() {
  apt-get install -y ${DEB_PACKAGES[*]}
}

apt-get update -y
install_deb_packages
