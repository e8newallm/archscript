username=$1
install_gui=$2

# Copy config files to new system

echo "Copying config files..."

if ${install_gui} ; then
# Lightdm
	cp configs/etc/lightdm/lightdm.conf /mnt/etc/lightdm
	cp configs/etc/lightdm/slick-greeter.conf /mnt/etc/lightdm

# xfce4
	mkdir -p /mnt/home/${username}/.config
	cp -r configs/xfce4 /mnt/home/${username}/.config/

fi

# Set user as owner for whole home dir
arch-chroot /mnt chown -R ${username}:${username} /home/${username}
