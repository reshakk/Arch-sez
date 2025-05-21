#!/usr/bin/env bash

pipewire=(
    pipewire
    wireplumber
    pipewire-audio
    pipewire-alsa
    pipewire-pulse
    sof-firmware
)


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_func.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_pipewire.log"

# Disabling pulseaudio to avoid conflicts
systemctl --user disable --now pulseaudio.socket pulseaudio.service 2>/dev/null && tee -a "$LOG"

# Pipewire
for PIPEWIRE in "${pipewire[@]}"; do
    install_package "$PIPEWIRE" 2>&1 | tee -a "$LOG"
done

# Enable services
systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service 2>&1 | tee -a "$LOG"
systemctl --user enable --now pipewire.service 2>&1 | tee -a "$LOG"

# Completion message
gum format --type markdown << EOM | tee -a "$LOG"
# Installation Complete
Pipewire packages and services have been installed and activated.
Check the log file at '$LOG' for details.
EOM

sleep 2

clear
