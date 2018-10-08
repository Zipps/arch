# Arch Installation

Scripts for a quick install of ArchLinux on a preconfigured system.

## Instructions

### Connect to the internet (if on WiFi)

echo -en "$WIFI_PASSPHRASE" | wpa_passphrase $SSID >> /etc/wpa_supplicant.conf
wpa_supplicant -B -D wext -i $WIFI_ADAPTER -c /etc/wpa_supplicant.conf
dhcpcd $WIFI_ADAPTER

### Script

Clone the script repo and run the pre_install script.

The system will reboot when complete.

### After reboot

Now login and add the user to the suders file

Run the post_install script, which will be located in the users home folder


## Final

Remove Boot from USB option
Add BIOS password
Pull configuration files
