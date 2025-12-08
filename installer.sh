set -e
clear

install_drive=/dev/sda
encrypt_root=false
hostname=Matt-machine
username=Matt-machine
# Get flags
while [ $# -gt 0 ]; do
	case "$1" in
		-d|--drive)
			if [ $# -lt 2 ]; then
				echo "ERROR: Drive not specified!"
				exit 1
			fi

			if [ ! -b $2 ]; then
				echo "ERROR: \"$2\" is not a drive!"
				exit 1
			fi

			install_drive="$2"
			shift
			shift
			;;

		-e|--encrypt)
			encrypt_root=true
			shift
			;;

		-h|--hostname)
			if [ $# -lt 2 ]; then
				echo "ERROR: Hostname not specified!"
				exit 1
			fi

			hostname="$2"
			shift
			shift
			;;

		-u|--username)
			if [ $# -lt 2 ]; then
				echo "ERROR: Username not specified!"
				exit 1
			fi

			username="$2"
			shift
			shift
			;;
	esac
done

echo "Install configuration:"
echo "Drive: ${install_drive}"
echo "Encrypt root: ${encrypt_root}"
echo "Hostname: ${hostname}"
echo "Username: ${username}"
echo ""
echo "Is this correct (y/N): "
read correct_config

if [ ${correct_config} != "y" ] ; then
	echo "Closing install"
	exit 0
fi

echo -e "\r\n###########################################################\r\nStarting install...\r\n"

stages/base-setup.sh ${install_drive} ${encrypt_root}

cp stages/arch-chroot.sh /mnt/
arch-chroot /mnt bash -c "/arch-chroot.sh ${hostname} ${username} ${encrypt_root} ${install_drive}"
rm /mnt/arch-chroot.sh
