SSID=""
WIFI_PASSPHRASE=""
WIFI_ADAPTER="wlp1s0"
USERNAME=""
USERPW=""

# setup network manager
systemctl enable NetworkManager
systemctl start NetworkManager
nmcli d wifi connect $SSID password $WIFI_PASSPHRASE iface $WIFI_ADAPTER

# get best mirrors
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.backup
rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist
vim /etc/pacman.d/mirrorlist

# create user
useradd -m -g wheel -s /bin/bash $USERNAME
echo -en "$USERPW\n$USERPW" | passwd $USERNAME

# install packages
packman -S gnome gnome-extra gdm

# enable display manager
systemctl enable gdm
systemctl start gdm.service

# password protect GRUB at boot
echo -en "" | PBKDF2=grub-mkpasswd-pbkdf2
set superusers=$USERNAME
password_pbkdf2 $USERNAME $PBKDF2
grub-mkconfig -o /boot/grub/grub.cfg