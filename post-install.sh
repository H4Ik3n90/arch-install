# !/bin/sh

# clear entire screen
clear 

# initialize some color
GREEN="\033[0;32m"
CYAN="\033[0;36m"

# System Configuration logo
echo -e "\n"
echo -e "${GREEN} ###################################"
echo -e "${GREEN} #        ${CYAN}Configure System${GREEN}         #"
echo -e "${GREEN} ###################################"

# get user timezone 
echo -ne "\n Enter your timezone(/region/city)? "
read USER_TIMEZONE

# setting user timezone and sync it
ln -sf /usr/share/zoneinfo/$USER_TIMEZONE /etc/localtime
hwclock --systohc 

# setting systme locale 
echo -ne "\n Enter your locale(default input)? "
read USER_LOCALE

# uncomment selected locale
sed '/pattern/s^#//' -i /etc/locale.gen

# generate locale-gen file
locale-gen

# set locale in conf file
echo LANG=en_US.UTF-8 >> /etc/locale.conf

# system Configuration logo
echo -e "\n"
echo -e "${GREEN} ###################################"
echo -e "${GREEN} #        ${CYAN}Configure Network${GREEN}        #"
echo -e "${GREEN} ###################################"

# get user hostname
echo -ne "\n Enter your hostname here? "
read USER_HOSTNAME 

# set user hostname 
echo $USER_HOSTNAME >> /etc/hostname

# setup hostfiles
cat << EOT >>  /etc/hosts

127.0.0.1	localhost
::1		localhost
127.0.1.1	$USER_HOSTNAME.localdomain myhostname
EOT 

# configure some packages 
echo -e "\n"
echo -e "${GREEN} ###################################"
echo -e "${GREEN} #        ${CYAN}Configure Packages${GREEN}       #"
echo -e "${GREEN} ###################################"

# download and install some packages
pacman -Sy networkmanager wpa_supplicant bluez bluez-utils cups grub grub-btrfs os-prober efibootmgr

# setting up some packages

# configure new user
echo -e "\n"
echo -e "${GREEN} ###################################"
echo -e "${GREEN} #        ${CYAN}Configure Newuser${GREEN}        #"
echo -e "${GREEN} ###################################"

# set root password
passwd

# get new username and passwd from user 
echo -ne "${CYAN}\n Enter new username? "
read USER_NEW_USERNAME

echo -ne "${CYAN}\n Enter new password? "
read USER_NEW_PASSWORD

# add new user and password
useradd -mG wheel $USER_NEW_USERNAME
passwd $USER_NEW_PASSWORD

