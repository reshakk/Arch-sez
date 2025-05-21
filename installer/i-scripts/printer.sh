#!/usr/bin/env bash

printer=(
	cups
	hplip	
)

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_func.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_printer.log"

for RPG in "${printer[@]}"; do
	install_package_pacman "$RPG" 2>&1 | tee -a "$LOG"
done

sudo systemctl enable --now cups

# Completion message
gum format --type markdown << EOM | tee -a "$LOG"
# Installation Complete
Hp packages and services have been installed and activated.
Check the log file at '$LOG' for details.
EOM

sleep 2

clear