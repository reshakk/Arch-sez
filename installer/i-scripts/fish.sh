#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_func.sh"
#source i-scripts/Global_func.sh

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_fish.log"

install_package_pacman "fish" 2>&1 | tee -a "$LOG"

while ! chsh -s $(which fish); do
	echo "Authentication failed. Please enter the correct password." 2>&1 | tee -a "$LOG"
	sleep 1
done

# Completion message
gum format --type markdown << EOM | tee -a "$LOG"
# Installation Complete
Fish have been installed and activated.
Check the log file at '$LOG' for details.
EOM

sleep 2

clear