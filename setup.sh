#!/usr/bin/env bash

if type termux-info &> /dev/null; then

apt-get update
apt-get --assume-yes upgrade
apt-get --assume-yes install coreutils gnupg wget termux-api openjdk-17 vim ncurses perl which
if [ ! -f "$PREFIX/etc/apt/sources.list.d/termux-adb.list" ]; then
    mkdir -p $PREFIX/etc/apt/sources.list.d
    echo -e "deb https://nohajc.github.io termux extras" > $PREFIX/etc/apt/sources.list.d/termux-adb.list
    wget -qP $PREFIX/etc/apt/trusted.gpg.d https://nohajc.github.io/nohajc.gpg
    apt update
    apt install termux-adb
else
    echo "termux-adb already installed"
    apt install termux-adb
fi
echo "done!"

elif type fastboot &> /dev/null; then

echo "Fastboot is already installed"

else

echo "I didn't find fastboot, please install it before proceeding."

fi
