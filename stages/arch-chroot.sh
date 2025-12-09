hostname=$1
username=$2
encrypt_root=$3
install_drive=$4
install_gui=$5

echo "Setting up localization..."
# Set the time zone
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc

# Localization
echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

echo "LANG=en_GB.UTF-8" > /etc/locale.conf
echo "KEYMAP=uk" > /etc/vconsole.conf

echo "${hostname}" > /etc/hostname

# Basic pacman installs
echo "Installing basic tools..."
pacman -Sy
pacman -S sudo less nvim git plymouth xdg-user-dirs networkmanager --noconfirm

systemctl enable NetworkManager

# Add wheel group to sudoers
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers

# Installing grub
echo "Setting up grub..."
pacman -S grub efibootmgr --noconfirm

if ${encrypt_root} ; then
	echo "Setting up encrypted partition loading..."
	sed -i '/^HOOKS=/ s/block/block plymouth sd-encrypt/' /etc/mkinitcpio.conf
	sed -i '/#GRUB_ENABLE_CRYPTODISK/ s/#GRUB/GRUB/' /etc/default/grub
	encrypt_config=$(blkid -s UUID -o value ${install_drive}2)
	sed -i "/GRUB_CMDLINE_LINUX_DEFAULT/ s/loglevel=3/rd\.luks\.name=${encrypt_config}=root root=\/dev\/mapper\/root loglevel=3/" /etc/default/grub
fi
mkinitcpio -P

grub-install --target=x86_64-efi --efi-directory=boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Create user
echo "Creating user account ${username}..."
useradd -m -G wheel ${username}
xdg-user-dirs-update
passwd ${username}

# Disable root
echo "Disabling root account..."
usermod -s /usr/sbin/nologin root

# Pull nvim config
echo "Pulling nvim config..."
(cd /home/${username}/.config && git pull github.com/e8newallm/nvim)

# Install GUI
if ${install_gui} ; then
	echo "Installing GUI..."
	pacman -S lightdm lightdm-slick-greeter xfce4 xfce4-goodies archlinux-wallpaper --noconfirm
	systemctl enable lightdm.service	
fi
