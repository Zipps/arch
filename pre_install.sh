# parameters
BEFOREWIFI=true
MYHOSTNAME="arch"
SSID=""
WIFI_PASSPHRASE=""
WIFI_ADAPTER="wlp1s0"

ROOT_PASSWORD=""
DRIVE_PASSPHRASE=""
BOOT_DRIVE="/dev/nvme0n1p1"
ROOT_DRIVE="/dev/nvme0n1p4"
WINDOWS_BOOT="/dev/nvme0n1p2"
CRYPT_NAME="cryptroot"
ROOT_MAP="/dev/mapper/$CRYPT_NAME"

MAP_DRIVE="/dev/mapper/arch-root"
SWAP_DRIVE="/dev/mapper/arch-swap"

# larger font
setfont sun12x22

# update system clock
timedatectl set-ntp true

# encrypt partition
echo -en "$DRIVE_PASSPHRASE" | cryptsetup -c aes-xts-plain -y -s 512 luksFormat "$ROOT_DRIVE"
echo -en "$DRIVE_PASSPHRASE" | cryptsetup luksOpen "$ROOT_DRIVE" $CRYPT_NAME

pvcreate /dev/mapper/$CRYPT_NAME
vgcreate arch /dev/mapper/$CRYPT_NAME
lvcreate -L +8G arch -n swap
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
pacstrap /mnt base base-devel grub efibootmgr os-prober git intel-ucode networkmanager

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
mkdir /mnt/windows
mount $WINDOWS_BOOT /mnt/windows 
grub-mkfont --output=/boot/grub/fonts/DejaVuSansMono20.pf2 \ --size=20 /usr/share/fonts/TTF/dejavu/DejaVuSansMono.ttf
echo "menuentry \"System shutdown\" {
	echo \"System shutting down...\"
	halt
}" >> /etc/grub.d/40_custom
echo "menuentry \"System restart\" {
	echo \"System rebooting...\"
	reboot
}" >> /etc/grub.d/40_custom
fs_uuid=grub-probe --target=fs_uuid esp/EFI/Microsoft/Boot/bootmgfw.efi
hints_string=grub-probe --target=hints_string esp/EFI/Microsoft/Boot/bootmgfw.efi
echo "menuentry \"Microsoft Windows\" {
		insmod part_gpt
		insmod fat
		insmod search_fs_uuid
		insmod chain
		search --fs-uuid --set=root $hints_string $fs_uuid
		chainloader /EFI/Microsoft/Boot/bootmgfw.efi
}" >> /etc/grub.d/40_custom
vim /etc/defaults/grub
grub-install --target=x86_64-efi --recheck --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# finish and reboot
exit
umount -R /mnt
reboot
