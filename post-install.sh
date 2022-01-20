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

# uncomment selected locale
sed '/en_US.UTF-8 UTF-8/s^#//' -i /etc/locale.gen

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

echo -ne "${CYAN}\n Are you using btrfs file system(y/n)? "
read USER_FILESYSTEM

if [ $USER_FILESYSTEM == 'y']
then 
    # download and install some packages
    pacman -Sy iwd networkmanager wpa_supplicant cups dialog grub grub-btrfs os-prober efibootmgr

elif [ $USER_FILESYSTEM == 'n' ]
then 
    # download and install some packages
    pacman -Sy networkmanager wpa_supplicant cups dialog grub os-prober efibootmgr
fi 

# setting up some packages
systemctl enable wpa_supplicant
systemctl start wpa_supplicant

systemctl enable NetworkManager 
systemctl start NetworkManager

systemctl enable cupsd
systemctl start cupsd

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

# enable user wheel to access root 
EDITOR=nano visudo

# configure grub bootloader
echo -e "\n"
echo -e "${GREEN} ###################################"
echo -e "${GREEN} #        ${CYAN}Configure Grub${GREEN}           #"
echo -e "${GREEN} ###################################"

if [ $USER_FILESYSTEM == 'y']
then 
    # add btrfs module to mkinitcpio
    echo "MODULES=(btrfs)" >> /etc/mkinitcpio.conf  

    # create image 
    mkinitcpio -p linux 

    # installing grub 
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch

    # generate bootloader config file
    grub-mkconfig -o /boot/grub/grub.cfg 

elif [ $USER_FILESYSTEM == 'n' ]
then 
    # installing grub 
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch

    # generate bootloader config file
    grub-mkconfig -o /boot/grub/grub.cfg

fi 

# exit and umount all mounted partition
exit
umount -R /mnt  

echo -ne "${CYAN}\n Installation has finished"