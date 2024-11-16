#!/usr/bin/env bash

flatpaks=(
	net.davidotek.pupgui2 #ProtonQt
	com.usebottles.bottles 
	com.github.tchx84.Flatseal
        dev.vencord.Vesktop	
	io.github.flattool.Warehouse
	com.nextcloud.desktopclient.nextcloud
	io.github.thetumultuousunicornofdarkness.cpu-x
)

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_flatpak.log"

if pacman -Q flatpak &>/dev/null; then
	echo "Flatpak is already installed"
else
	echo "Installing flatpak"
	sudo pacman -S --noconfirm flatpak 2>&1 | tee -a "$LOG"
	if pacman -Q flatpak &>/dev/null; then
		echo "Flatpak was installed"
	else
		echo -e "Flatpak failed to install. Please check the $LOG"
		exit 1
	fi
fi

for RPG in "${flatpaks[@]}"; do
	if flatpak info "$RPG" &>/dev/null; then
		echo "$RPG is already installed"
	else
		echo "Installing $RPG"
		flatpak install "$RPG" --noninteractive 2>&1 | tee -a "$LOG"
		if flatpak info "$RPG" &>/dev/null; then
			echo "$RPG was installed"
		else
			echo -e "$RPG failed to install. Please check the $LOG."
			exit 1
		fi
	fi
done

flatpak override --user com.usebottles.bottles --filesystem=xdg-data/Steam
flatpak install flathub org.freedesktop.Platform.VulkanLayer.MangoHud --noninteractive	
