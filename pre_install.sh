#!/bin/bash

# pull config
source ./config/config

# larger font
setfont sun12x22

# connect to wifi
if ! [ -z $WIFI_ADAPTER ]; then
	echo -en "$WIFI_PASSPHRASE" | wpa_passphrase $SSID >> /etc/wpa_supplicant.conf
	wpa_supplicant -B -D wext -i $WIFI_ADAPTER -c /etc/wpa_supplicant.conf
	dhcpcd $WIFI_ADAPTER
fi

# update system clock
timedatectl set-ntp true

# encrypt partition
echo -en "$DRIVE_PASSPHRASE" | cryptsetup -c aes-xts-plain -y -s 512 luksFormat "$ROOT_DRIVE"
echo -en "$DRIVE_PASSPHRASE" | cryptsetup luksOpen "$ROOT_DRIVE" $CRYPT_NAME

pvcreate /dev/mapper/$CRYPT_NAME
vgcreate arch /dev/mapper/$CRYPT_NAME
lvcreate -L +$SWAP_SIZE arch -n swap
lvcreate -l +100%FREE arch -n root

# Create filesystems on your encrypted partitions
mkswap $SWAP_DRIVE
mkfs.ext4 $MAP_DRIVE

# mount filesystems
mount $MAP_DRIVE /mnt
swapon $SWAP_DRIVE
mkdir /mnt/boot
mount $BOOT_DRIVE /mnt/boot

# bootstrapping
pacstrap /mnt base base-devel git intel-ucode networkmanager

# fstab
genfstab -U /mnt >> /mnt/etc/fstab

# system setup
arch-chroot /mnt
ln -sf $MYLOCALE /etc/localtime
hwclock --systohc

# set root password
echo -en "$ROOT_PASSWORD\n$ROOT_PASSWORD" | passwd

# create user
useradd -m -g wheel -s /bin/bash $USERNAME
echo -en "$USERPW\n$USERPW" | passwd $USERNAME

# config files
sed -i $MYLOCALESED /etc/locale.gen && locale-gen
echo $MYHOSTNAME > /etc/hostname
echo $MYLANG >> /etc/locale.conf
cat /etc/hosts ./config/hosts > /etc/hosts

# modify MKINITCPIO
cp -f ./config/mkinitcpio /etc/mkinitcpio.conf
mkinitcpio -p linux

# setup BOOTLOADER
cp -f ./config/boot /boot/loader/loader
cp -f ./config/arch_boot /boot/loader/entries/arch

# finish and reboot
exit
cp ./post_install /mnt/user/$USERNAME
cp ./config/config /mnt/user/$USERNAME
umount -R /mnt
reboot
