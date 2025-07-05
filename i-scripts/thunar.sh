#!/usr/bin/env bash

#if [[ $USE_PRESET = [Yy] ]]; then
#  source ./preset.sh
#fi

thunar=(
  thunar
  thunar-volman
  tumbler
  ffmpegthumbnailer
  file-roller
  thunar-archive-plugin
)

printf "\n%.0s" {1..2}
echo -e "\e[35m
        ###############
         THUNAR SCRIPT
        ###############
\e[0m"
printf "\n%.0s" {1..1}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_func.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_thunar.log"

for RPG in "${thunar[@]}"; do
	install_package_pacman "$RPG" 2>&1 | tee -a "$LOG"
done

