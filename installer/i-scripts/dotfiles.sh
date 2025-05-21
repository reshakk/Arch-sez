#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_func.sh"

if [ -d Arch-dotfiles ]; then
	cd Arch-dotfiles
	chmod +x copy.sh
	./copy.sh
else
	if git clone --depth 1 https://github.com/reshakk/Arch-dotfiles.git; then
		cd Arch-dotfiles || exit 1
		chmod +x copy.sh
		./copy.sh
	else
	    gum style --border double --border-foreground 1 "[ERROR] Failed to download dotfiles."
	fi
fi


clear
