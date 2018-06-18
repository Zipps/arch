# Instructions

Run the pre_install script.

During the script run there will be two instances where the VIM will be opened to modify a config file. Ensure that the config is set up as described in the sections below.

## Hooks
HOOKS="base udev autodetect modconf block encrypt resume filesystems keyboard fsck"


## Grub
GRUB_CMDLINE_LINUX="cryptdevice=/dev/nvme0n1p4:cryptroot"
GRUB_ENABLE_CRYPTODISK=y