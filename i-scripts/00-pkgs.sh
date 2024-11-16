#!/usr/bin/env bash

unins=(
	dunst
	htop
	dolphin
	wofi
)

Extra=(
	graphite-gtk-theme
	wps-office
	hyprshot
	wlogout
)

#Unnecessary packages
une_package=(
	steam	
	gedit
	obsidian
	atril
	qbittorrent
	wine
	filelight
	qalculate-gtk
	btop
)


#Importen package for Hyprland
main_package=(	
	vim
	cliphist
	kitty
	shotwell
	pavucontrol
	playerctl
	meson
	wl-clipboard
	yad	
	rofi
	rofi-calc
	swaync
	swww
	swaybg
	nwg-look
	hypridle
	waybar
	hyprlock
	hyprpicker
)


#Standart command for terminal
stnd_com=(
	less
	git
	zip
	unzip
	rsync
	cron
	curl
	man
	wget	
	nmap
)

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_func.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprpkg.log"

# uninstalling conflicting packages
# Initialize a variable to track overall errors
overall_failed=0

for RPG in "${unins[@]}"; do
  uninstall_package "$RPG" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    # Track if any uninstallation failed
    overall_failed=1
  fi
done

if [ $overall_failed -ne 0 ]; then
  echo -e "Some packages failed to uninstall. Please check the log."
fi

#Main packages
for RPG in "${une_package[@]}" "${main_package[@]}" "${stnd_com[@]}"; do
	install_package_pacman "$RPG" 2>&1 | tee -a "$LOG"
done

#Extra packages
for RPG in "${Extra[@]}"; do
	install_package "$RPG" 2>&1 | tee -a "$LOG"
done



clear
