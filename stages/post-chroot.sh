install_gui=$1

# Copy config files to new system

echo "Copying config files..."

if ${install_gui} ; then
	cp configs/etc/lightdm/lightdm.conf /mnt/etc/lightdm
	cp configs/etc/lightdm/slick-greeter.conf /mnt/etc/lightdm
fi
