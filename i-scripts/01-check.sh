#!/usr/bin/env bash

package=(
	hyprshot
	cliphist
	kitty
	pavucontrol
	wl-clipboard
	rofi
	swaync
	swww
	swaybg
	hypridle
	waybar
	hyprlock
	hyprpicker
	hyprland
)

printf "\n%.0s" {1..2}  
echo -e "\e[35m
        #############
         FINAL CHECK
        #############
\e[0m"
printf "\n%.0s" {1..1} 

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_func.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_01-check.log"

echo ""

# Initialize an empty array to hold missing packages
missing=()

for rpg in "${package[@]}"; do
	if ! pacman -Qi "$rpg" > /dev/null; then
		missing+=("$rpg")
	fi
done

if [[ ${#missing[@]} -eq 0 ]]; then
	echo -e "${OK} All package are installed." | tee -a "$LOG"
else
	echo -e "${INFO} The following packages are missing and will be logged."

	for rgp in "${missing[@]}"; do
		echo "$rpg"
		echo "$rpg" >> "$LOG"
	done

	echo "Missing packages are logged at $(date)" >> "$LOG"
	sleep 1s
fi

