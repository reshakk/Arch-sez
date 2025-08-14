#!/usr/bin/env bash

amd=(
	mangohud
	mesa
	vulkan-radeon
	vulkan-intel
	intel-media-driver
	libva-intel-driver
	xf86-video-ati	
	xf86-video-amdgpu
	xf86-video-intel
	xorg-server
	xorg-xinit
)

printf "\n%.0s" {1..2}  
echo -e "\e[35m
        #################
         SOFTWARE SCRIPT
        #################
\e[0m"
printf "\n%.0s" {1..1} 

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_func.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_software.log"

for RPG in "${amd[@]}"; do
	install_package_pacman "$RPG" 2>&1 | tee -a "$LOG"
done

# Some times this option can slow down performance in some apps
sudo touch "/etc/sysctl.d/99-splitlock.conf"
echo "kernel.split_lock_mitigate=0" | sudo tee > "/etc/sysctl.d/99-splitlock.conf"

# Increase amd shader cache size
sudo touch "/etc/profile.d/increase-shadercache.sh"
echo -e "export AMD_VULKAN_ICD=RADV
export MESA_SHADER_CACHE_MAX_SIZE=12G" | sudo tee > "/etc/profile.d/increase-shadercache.sh"
