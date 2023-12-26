#!/usr/bin/env bash

if type termux-info &> /dev/null; then

apt-get update
apt-get --assume-yes upgrade
apt-get --assume-yes install coreutils gnupg wget termux-api openjdk-17 vim ncurses perl which

if [ ! -f "$PREFIX/etc/apt/sources.list.d/mi-fastboot.list" ]; then
    mkdir -p "$PREFIX/etc/apt/sources.list.d"
    echo -e "deb https://rohitverma882.github.io termux extras" > "$PREFIX/etc/apt/sources.list.d/mi-fastboot.list"
    wget -qP "$PREFIX/etc/apt/trusted.gpg.d" "https://rohitverma882.github.io/rohit.gpg"
    apt update
    apt install mi-fastboot
else
    echo "Repo already installed"
    apt install mi-fastboot
fi

echo "done!"


elif type fastboot &> /dev/null; then

echo "Fastboot is already installed"

else

echo "I didn't find fastboot, please install it before proceeding."

fi

