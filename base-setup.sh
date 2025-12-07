install_drive=$1
encrypt_root=$2

# Set keys to be uk layout
loadkeys uk

# Test connection to Arch servers
if ! ping ping.archlinux.org -c 1; then
	echo "No network connection!"
	exit 1
fi
echo "Network connection found..."

# Sync the system clock
timedatectl

# Setup the drive
echo "Partitioning the drive: ${install_drive}..."

# Boot partition
boot_partition=${install_drive}1
echo "Setting up boot partition at ${boot_partition}..."
parted $install_drive --script mklabel gpt
parted /dev/sda --script mkpart ESP fat32 1MiB 1025MiB
parted /dev/sda --script set 1 esp on
mkfs.fat -F32 ${boot_partition}

# Root partition
root_partition=${install_drive}2
parted /dev/sda --script mkpart primary ext4 1025MiB 100%
if [ ${encrypt_root} ]; then
	echo "Encrypting the root partition..."
	if ! cryptsetup luksFormat ${root_partition} ; then
		echo "ERROR: Failed to encrypt ${root_partition}!"
		exit 1
	fi

	echo "Mounting encrypted partition as a device mapper..."
	if ! cryptsetup open ${root_partition} root ; then
		echo "ERROR: Failed to mount ${root_partition}!"
		exit 1
	fi

	echo "Root drive ${root_partition} encrypted and mounted to /dev/mapper/root"
	root_partition=/dev/mapper/root
fi

echo "Setting up root partition at ${root_partition}..."
mkfs.ext4 ${root_partition}

# Mounting filesystem
echo "Mounting partitions into a filesystem..."
mount ${root_partition} /mnt
mkdir /mnt/boot
mount ${boot_partition} /mnt/boot

# Installing base system
echo "Setting up base system..."

pacstrap -K /mnt base linux-hardened linux-firmware sudo vim git amd-ucode intel-ucode man
genfstab -U /mnt >>/mnt/etc/fstab
