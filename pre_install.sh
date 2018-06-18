# parameters
MYHOSTNAME="arch"
SSID=""
WIFI_PASSPHRASE=""
WIFI_ADAPTER="wlp1s0"

ROOT_PASSWORD=""
DRIVE_PASSPHRASE=""
BOOT_DRIVE="/dev/nvme0n1p1"
ROOT_DRIVE="/dev/nvme0n1p4"
CRYPT_NAME="cryptroot"
MAP_DRIVE="/dev/mapper/$CRYPT_NAME"

# connect to internet
wpa_supplicant -B -i $WIFI_ADAPTER -c <(wpa_passphrase "$SSID" "$WIFI_PASSPHRASE")
dhclient $WIFI_ADAPTER

# update system clock
timedatectl set-ntp true

# encrypt partition
echo -en "$DRIVE_PASSPHRASE" | cryptsetup -c aes-xts-plain -y -s 512 luksFormat "$ROOT_DRIVE"
echo -en "$DRIVE_PASSPHRASE" | cryptsetup luksOpen "$ROOT_DRIVE" $CRYPT_NAME

# format drive
mkfs.ext4 $MAP_DRIVE

# mount filesystems
mount $MAP_DRIVE /mnt
mkdir /mnt/boot
mount $BOOT_DRIVE /mnt/boot

# get best mirrors
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.backup
rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist
vim /etc/pacman.d/mirrorlist

# bootstrapping
pacstrap /mnt base base-devel grub efibootmgr os-prober git wpa_supplicant dhclient intel-ucode

# fstab
genfstab -U /mnt >> /mnt/etc/fstab

# system setup
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Australia/Brisbane /etc/localtime
hwclock --systohc

# set root password
echo -en "$ROOT_PASSWORD\n$ROOT_PASSWORD" | passwd

# config files
sed -i 's/#en_AU.UTF-8 UTF-8/en_AU.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo $MYHOSTNAME > /etc/hostname
echo LANG=en_AU.UTF-8 >> /etc/locale.conf
echo LANGUAGE=en_AU >> /etc/locale.conf
echo LC_ALL=C >> /etc/locale.conf
export LANG=en_AU.UTF-8
echo "127.0.0.1	localhost" >> /etc/hosts
echo "::1		localhost" >> /etc/hosts
echo "127.0.1.1 $MYHOSTNAME.localdomain  $MYHOSTNAME" >> /etc/hosts

# modify MKINITCPIO
vim /etc/mkinitcpio.conf
mkinitcpio -p linux

# setup GRUB
vim /etc/defaults/grub
grub-install --target=x86_64-efi --recheck --efi-directory=/boot/EFI --bootloader-id=GRUB
grub-mkconfig -o /boot/EFI/grub/grub.cfg


# finish and reboot
exit
umount -R /mnt
reboot