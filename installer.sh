set -e
clear

install_drive=/dev/sda
encrypt_root=false

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
	esac
done

echo "Install configuration:"
echo "Drive: ${install_drive}"
echo "Encrypt root: ${encrypt_root}"
echo ""
echo "Is this correct (y/N): "
read correct_config

if [ ${correct_config} != "y" ] ; then
	echo "Closing install"
	exit 0
fi

echo -e "\r\n###########################################################\r\nStarting install...\r\n"

./base-setup.sh ${install_drive} ${encrypt_root}
