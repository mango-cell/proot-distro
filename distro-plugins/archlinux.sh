##
## Plug-in for installing Arch Linux (original and ARM variants).
##

DISTRO_NAME="Arch Linux"

# x86_64 rootfs is inside subdirectory.
if [ "$(uname -m)" = "x86_64" ]; then
	DISTRO_TARBALL_STRIP_OPT=1
fi

# Returns download URL.
get_download_url() {
	case "$(uname -m)" in
		aarch64)
			echo "https://eu.mirror.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz"
			;;
		armv7l|armv8l)
			echo "https://eu.mirror.archlinuxarm.org/os/ArchLinuxARM-armv7-latest.tar.gz"
			;;
		x86_64)
			# File name of x86_64 tarball is not persistent, so generate URL in hacky way.
			local file_name
			file_name=$(curl --fail --silent "https://mirror.rackspace.com/archlinux/iso/latest/md5sums.txt" | grep bootstrap | awk '{ print $2 }')
			if [ -n "$file_name" ]; then
				echo "http://mirror.rackspace.com/archlinux/iso/latest/${file_name}"
			fi
			;;
	esac
}

# Define here additional steps which should be executed
# for configuration.
distro_setup() {
	# Enable the first found mirror. Needed only for x86_64 as
	# ArchLinuxARM has geoip-based mirror enabled by default.
	if [ "$(uname -m)" = "x86_64" ]; then
		sed -i 's/#Server = http/Server = http/' ./etc/pacman.d/mirrorlist
	fi

	# Pacman keyring initialization.
	run_proot_cmd pacman-key --init
	if [ "$(uname -m)" = "x86_64" ]; then
		run_proot_cmd pacman-key --populate archlinux
	else
		run_proot_cmd pacman-key --populate archlinuxarm
	fi
}
