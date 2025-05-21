#!/usr/bin/env bash

flatpaks=(
	net.davidotek.pupgui2 #ProtonQt
        net.lutris.Lutris #Launcher on wine
        com.github.tchx84.Flatseal #Control the settings for the app from flathub
        dev.vencord.Vesktop #Discord with screen-sharing        
        io.github.flattool.Warehouse #Manage all things Flatpak 
        com.nextcloud.desktopclient.nextcloud #Self-storage
        io.github.thetumultuousunicornofdarkness.cpu-x #Informations on CPU
        io.missioncenter.MissionCenter #Monitor system
        com.rabbit_company.passky #Password-manager
)

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_flatpak.log"

if pacman -Q flatpak &>/dev/null; then
	gum style --border normal --border-foreground 4 --padding "1 2" "[INFO] Flatpak is already installed."
else
	gum spin --spinner dot --title "Installing Flatpak..." -- \
		sudo pacman -S --noconfirm flatpak 2>&1 | tee -a "$LOG"
	if pacman -Q flatpak &>/dev/null; then
		gum style --border normal --border-foreground 4 --padding "1 2" "[INFO] Flatpak was installed."
	else
		gum style --border normal --border-foreground 1 --padding "1 2" "[ERROR] Flatpak failed to install. Please check the $LOG."
		exit 1
	fi
fi

for RPG in "${flatpaks[@]}"; do
	if flatpak info "$RPG" &>/dev/null; then
		gum style --border normal --border-foreground 4 --padding "1 2" "[INFO] $RPG is already installed."
	else
		gum spin --spinner dot --title "Installing $RPG..." -- \
			flatpak install "$RPG" --noninteractive 2>&1 | tee -a "$LOG"
		if flatpak info "$RPG" &>/dev/null; then
			gum style --border normal --border-foreground 4 --padding "1 2" "[INFO] $RPG was installed."
		else
			gum style --border normal --border-foreground 1 --padding "1 2" "[ERROR] $RPG failed to install. Please check the $LOG."
			exit 1
		fi
	fi
done

flatpak override --user com.usebottles.bottles --filesystem=xdg-data/Steam
flatpak install flathub org.freedesktop.Platform.VulkanLayer.MangoHud --noninteractive	

# Completion message
gum format --type markdown << EOM | tee -a "$LOG"
# Installation Complete
Flatpak packages have been installed.
Check the log file at '$LOG' for details.
EOM

sleep 2

clear