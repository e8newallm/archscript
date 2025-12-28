username=$1
install_gui=$2

# Copy config files to new system

echo "Copying config files..."

if ${install_gui} ; then
# Lightdm
	cp configs/etc/lightdm/lightdm.conf /mnt/etc/lightdm
	cp configs/etc/lightdm/slick-greeter.conf /mnt/etc/lightdm

# Xorg keyboard
	cp configs/etc/X11/xorg.conf.d/00-keyboard.conf /mnt/etc/X11/xorg.conf.d/

# xfce4
	mkdir -p /mnt/home/${username}/.config
	cp -r configs/xfce4 /mnt/home/${username}/.config/

# Add samba drive
	echo "//server/data                                   /server         cifs            file_mode=0777,dir_mode=0777,password2=fake,guest,nofail,x-systemd.device-timeout=9             	0	0" >> /mnt/etc/fstab
fi

# Set user as owner for whole home dir
arch-chroot /mnt chown -R ${username}:${username} /home/${username}
