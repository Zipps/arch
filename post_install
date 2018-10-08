#!/bin/bash

# pull config
source ./config

# setup network manager
systemctl enable NetworkManager
systemctl start NetworkManager
nmcli d wifi connect $SSID password $WIFI_PASSPHRASE

# get best mirrors
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.backup
rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist
vim /etc/pacman.d/mirrorlist

# install packages
pacman -S $DEFAULT_PACKAGES
