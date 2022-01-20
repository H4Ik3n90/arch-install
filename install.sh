# !/bin/sh

# clear entire CLI screen
clear 

# initialize some color
GREEN="\033[0;32m"
CYAN="\033[0;36m"

# start logo
echo -e "${GREEN} ###################################"
echo -e "${GREEN} #     ${CYAN}Welcome to Arch Install${GREEN}     #"
echo -e "${GREEN} ###################################"

# opening cfdisk
echo -ne "${CYAN}\n Open disk partition using CFDISK\n\n"
cfdisk 

# ask user cpu 
echo -ne "${CYAN}\n What CPU do you use(intel/amd)? "
read USER_CPU
echo -ne "\n"

# setup partition logo 
echo -e "${GREEN} ###################################"
echo -e "${GREEN} #         ${CYAN}Setup Partition${GREEN}         #"
echo -e "${GREEN} ###################################"

# ask if user want to keep or formatt uefi partition
echo -ne "${CYAN}\n Do you want to format UEFI partition(y/n)? "
read UEFI_STAT

if [ $UEFI_STAT == 'y' ] 
then 
    # get partition info from user
    echo -ne "${CYAN}\n Enter your EFI partition(/dev/sda)? "
    read EFI_PARTITION

    echo -ne "${CYAN}\n Enter your file system partition(/dev/sda)? "
    read FS_PARTITION

    echo -ne "${CYAN}\n Enter your swap partition(/dev/sda)? "
    read SWAP_PARTITION

    # file system format choose
    echo -ne "${CYAN}\n\n File system partition format: "
    echo -ne "${CYAN}\n 1. Ext4(default)"
    echo -ne "${CYAN}\n 2. btrfs"
    echo -ne "${CYAN}\n\n Choose your partition format: "

    read PARTITION_CHOOSE

    if [ $PARTITION_CHOOSE == "1" ]
    then 
        # format efi partition
        mkfs.vfat -F 32 $EFI_PARTITION

        # format file system partition
        mkfs.ext4 $FS_PARTITION

        # format swap partition
        mkswap $SWAP_PARTITION

        # mount all partition
        mount $EFI_PARTITION /mnt/boot/efi 
        mount $FS_PARTITION /mnt 
        swapon $SWAP_PARTITION

    elif [ $PARTITION_CHOOSE == "2" ]
    then 
        # format file system partition
        mkfs.btrfs $FS_PARTITION

        # format swap partition
        mkswap $SWAP_PARTITION

        # mount all partition
        mount $EFI_PARTITION /mnt/boot/efi 
        mount $FS_PARTITION /mnt 
        swapon $SWAP_PARTITION
    
    fi

elif [ $UEFI_STAT == 'n' ]
then 
    # get partition info from user
    echo -ne "${CYAN}\n Enter your file system partition(/dev/sda)? "
    read FS_PARTITION

    echo -ne "${CYAN}\n Enter your swap partition(/dev/sda)? "
    read SWAP_PARTITION

    # file system format choose
    echo -ne "${CYAN}\n\n File system partition format: "
    echo -ne "${CYAN}\n 1. Ext4(default)"
    echo -ne "${CYAN}\n 2. btrfs"
    echo -ne "${CYAN}\n\n Choose your partition format: "

    read PARTITION_CHOOSE

    if [ $PARTITION_CHOOSE == "1" ]
    then 
        # format file system partition
        mkfs.ext4 $FS_PARTITION

        # format swap partition
        mkswap $SWAP_PARTITION

        # mount all partition 
        mount $FS_PARTITION /mnt 
        swapon $SWAP_PARTITION

    elif [ $PARTITION_CHOOSE == "2" ]
    then 
        # format file system partition
        mkfs.btrfs $FS_PARTITION

        # format swap partition
        mkswap $SWAP_PARTITION

        # mount all partition 
        mount $FS_PARTITION /mnt 
        swapon $SWAP_PARTITION
    
    fi 
fi

# Install partition logo
echo -e "\n"
echo -e "${GREEN} ###################################"
echo -e "${GREEN} #         ${CYAN}Install System${GREEN}          #"
echo -e "${GREEN} ###################################"

# ask btrfs partition
echo -ne "${CYAN}\n Are you using btrfs partition(y/n)"
read ASK_SYSTEM

# different packages in different file system format 
if [ $ASK_SYSTEM == 'n' ] 
then 
    if [ $USER_CPU == 'intel' ]
    then 
        # download and install system packages
        pacstrap /mnt base base-devel sudo nano firefox intel-ucode linux linux-firmware -y
   
    elif [ $USER_CPU == 'amd' ]  
    then 
        # download and install system packages
        pacstrap /mnt base base-devel sudo nano firefox amd-ucode linux linux-firmware -y

    fi
 
elif [ $ASK_SYSTEM == '2' ]
then 
    if [ $USER_CPU == 'intel' ]
    then 
        # download and install system packages
        pacstrap /mnt base base-devel sudo nano firefox btrfs-progs intel-ucode linux linux-firmware -y
   
    elif [ $USER_CPU == 'amd' ]  
    then 
        # download and install system packages
        pacstrap /mnt base base-devel sudo nano firefox btrfs-progs amd-ucode linux linux-firmware -y

    fi

fi 

# generate fstab file to file system partition
genfstab -U /mnt >> /mnt/etc/fstab

# copy file installation file to new partition
cd ../
cp -R ./arch-install /mnt 

# change root to new file system partition
arch-chroot /mnt