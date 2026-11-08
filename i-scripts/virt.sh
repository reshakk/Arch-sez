#!/usr/bin/env bash

virt=(
	qemu-full 
	libvirt 
	virt-manager 
	virt-viewer 
	edk2-ovmf 
	dnsmasq swtpm 
	guestfs-tools 
	libosinfo 
	tuned 
	spice-vdagent
)

printf "\n%.0s" {1..2}  
echo -e "\e[35m
        #################
           VIRT SCRIPT
        #################
\e[0m"
printf "\n%.0s" {1..1} 

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_func.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_virt.log"

for RPG in "${virt[@]}"; do
	install_package_pacman "$RPG" 2>&1 | tee -a "$LOG"
done


