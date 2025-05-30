#!/bin/bash
# SDDM Log-in Manager #

sddm=(
  qt6-5compat 
  qt6-declarative 
  qt6-svg
  sddm
)

# login managers to attempt to disable
login=(
  lightdm 
  gdm3 
  gdm 
  lxdm 
  lxdm-gtk3
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_func.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_sddm.log"


# Install SDDM and SDDM theme
for package in "${sddm[@]}"; do
    install_package "$package" "$LOG"
done 

printf "\n%.0s" {1..1}

# Check if other login managers installed and disabling its service before enabling sddm
for login_manager in "${login[@]}"; do
  if pacman -Qs "$login_manager" > /dev/null 2>&1; then
    sudo systemctl disable "$login_manager.service" >> "$LOG" 2>&1
    echo "$login_manager disabled." >> "$LOG" 2>&1
  fi
done

# Double check with systemctl
for manager in "${login[@]}"; do
  if systemctl is-active --quiet "$manager" > /dev/null 2>&1; then
    echo "$manager is active, disabling it..." >> "$LOG" 2>&1
    sudo systemctl disable "$manager" --now >> "$LOG" 2>&1
  fi
done

printf "\n%.0s" {1..1}
gum spin --spinner dot --title "Activating sddm service..." -- \
  sudo systemctl enable sddm


wayland_sessions_dir=/usr/share/wayland-sessions
[ ! -d "$wayland_sessions_dir" ] && { printf "$CAT - $wayland_sessions_dir not found, creating...\n"; sudo mkdir "$wayland_sessions_dir" 2>&1 | tee -a "$LOG"; }

printf "\n%.0s" {1..2}


# Completion message
gum format --type markdown << EOM | tee -a "$LOG"
# Installation Complete
Sddm packages and services have been installed and activated.
Check the log file at '$LOG' for details.
EOM

sleep 2

clear