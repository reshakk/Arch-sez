#!/usr/bin/env bash

printf "\n%.0s" {1..2}
echo -e "\e[35m
        #############
         FISH SCRIPT
        #############
\e[0m"
printf "\n%.0s" {1..1}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_func.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_fish.log"

install_package_pacman "fish" 2>&1 | tee -a "$LOG"

echo ""

while ! chsh -s $(which fish); do
	echo "${ERROR} Authentication failed. Please enter the correct password." 2>&1 | tee -a "$LOG"
	sleep 1
done
printf "Shell changed successfully to fish.\n" 2>&1 | tee -a "$LOG"
