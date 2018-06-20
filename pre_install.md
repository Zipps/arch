# Instructions

## Connect to the internet

### Easy
wifi-menu

### Hard
echo -en "$WIFI_PASSPHRASE" | wpa_passphrase $SSID >> /etc/wpa_supplicant.conf
wpa_supplicant -B -D wext -i $WIFI_ADAPTER -c /etc/wpa_supplicant.conf
dhclient $WIFI_ADAPTER

## Script

Clone the script repo.

Run the pre_install script.

During the script run there will be two instances where the VIM will be opened to modify a config file. Ensure that the config is set up as described in the sections below.

### Hooks
HOOKS="base udev autodetect modconf block encrypt lvm2 resume filesystems keyboard fsck"

### Grub
GRUB_CMDLINE_LINUX="cryptdevice=/dev/nvme0n1p4:cryptroot resume=/dev/mapper/arch-swap"
GRUB_ENABLE_CRYPTODISK=y
GRUB_FONT=/boot/grub/fonts/DejaVuSansMono20.pf2
