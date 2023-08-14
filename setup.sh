#!/data/data/com.termux/files/usr/bin/bash

apt-get update
apt-get --assume-yes upgrade
apt-get --assume-yes install coreutils gnupg wget termux-api openjdk-17 vim
if [ ! -f "$PREFIX/etc/apt/sources.list.d/mi-fastboot.list" ]; then
  mkdir -p $PREFIX/etc/apt/sources.list.d
  echo -e "deb https://rohitverma882.github.io termux extras" > $PREFIX/etc/apt/sources.list.d/mi-fastboot.list
  wget -qP $PREFIX/etc/apt/trusted.gpg.d https://rohitverma882.github.io/rohit.gpg
  apt update
  apt install mi-fastboot
else
  echo "Repo already installed"
  apt install mi-fastboot
fi

echo "done!"
