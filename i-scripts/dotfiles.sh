#!/usr/bin/env bash


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_func.sh"

if [ -d Hyprland-dot ]; then
	cd Hyprland-dot
	chmod +x copy.sh
	./copy.sh
else
	if git clone --depth 1 https://github.com/reshakk/Arch-dotfiles.git tmp/Hyprland-dot; then
		cd tmp/Hyprland-dot || exit 1
		chmod +x copy.sh
		./copy.sh
	else
		echo -e "${ERROR}Failed to download dotfiles."
	fi
fi


clear
