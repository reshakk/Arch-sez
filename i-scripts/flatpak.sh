#!/usr/bin/env bash

flatpaks=(
	net.davidotek.pupgui2 #ProtonQt
        com.github.tchx84.Flatseal #Control the settings for the app from flathub
        io.github.flattool.Warehouse #Manage all things Flatpak 
        io.github.thetumultuousunicornofdarkness.cpu-x #Informations on CPU
        org.kde.filelight #Show disk usage and delete unused files
        #com.rabbit_company.passky #Password-manager
)

printf "\n%.0s" {1..2}  
echo -e "\e[35m
	################
	 FLATPAK SCRIPT
	################
\e[0m"
printf "\n%.0s" {1..1} 



SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_func.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_flatpak.log"

if pacman -Q flatpak &>/dev/null; then
	echo -e "${OK} Flatpak is already installed"
else
	echo "Installing flatpak"
	sudo pacman -S --noconfirm flatpak 2>&1 | tee -a "$LOG"
	if pacman -Q flatpak &>/dev/null; then
		echo -e "${OK} Flatpak was installed"
	else
		echo -e "${ERROR} Flatpak failed to install. Please check the $LOG"
		sleep 2s
		exit 1
	fi
fi

for RPG in "${flatpaks[@]}"; do
	if flatpak info "$RPG" &>/dev/null; then
		echo -e "${OK} $RPG is already installed"
	else
		echo -e "${NOTE} Installing $RPG"
		flatpak install "$RPG" --noninteractive 2>&1 | tee -a "$LOG"
		if flatpak info "$RPG" &>/dev/null; then
			echo -e "${OK} $RPG was installed"
		else
			echo -e "${ERROR} $RPG failed to install. Please check the $LOG."
			sleep 2s
			exit 1
		fi
	fi
done

#flatpak override --user com.usebottles.bottles --filesystem=xdg-data/Steam
#flatpak install flathub org.freedesktop.Platform.VulkanLayer.MangoHud --noninteractive	
