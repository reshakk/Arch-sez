#!/usr/bin/env bash

package=(
	hyprshot
	cliphist
	kitty
	pavucontrol
	wl-clipboard
	rofi
	rofi-calc
	swaync
	swww
	swaybg
	hypridle
	waybar
	hyprlock
	hyprpicker
	hyprland
)


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_func.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_01-check.log"

gum style --border normal --border-foreground 4 --padding "1 2" "[INFO] Final Check: Verifying if essential packages were installed..."
# Initialize an empty array to hold missing packages
missing=()

for rpg in "${package[@]}"; do
	if ! pacman -Qi "$rpg" > /dev/null; then
		missing+=("$rpg")
	fi
done

if [[ ${#missing[@]} -eq 0 ]]; then
	gum style --border normal --border-foreground 4 --padding "1 2" "[INFO] All packages successfully installed." | tee -a "$LOG"
else
	gum style --border normal --border-foreground 1 --padding "1 2" "[ERROR] The following packages are missing and will be logged."

	for rgp in "${missing[@]}"; do
		echo "$rpg"
		echo "$rpg" >> "$LOG"
	done

	echo "Missing packages are logged at $(date)" >> "$LOG"
fi

