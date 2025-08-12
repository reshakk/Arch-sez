#!/usr/bin/env bash


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_func.sh"

HYPR_DIR="$HOME/Templates/git/Hyprland-dot"

mkdir -p "$HYPR_DIR"

if [ -d "$HYPR_DIR" ]; then
	cd "$HYPR_DIR"
	chmod +x copy.sh
	./copy.sh
else
	if git clone --depth 1 https://github.com/reshakk/Hyprland-dot.git "$HYPR_DIR"; then
		cd "$HYPR_DIR" || exit 1
		chmod +x copy.sh
		./copy.sh
	else
		echo -e "${ERROR}Failed to download dotfiles."
	fi
fi


clear
