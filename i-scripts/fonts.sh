#!/usr/bin/env bash

fonts=(
  # lib32-sdl2_ttf
  # lib32-sdl_ttf
  noto-fonts
  opendesktop-fonts
  # sdl2_ttf
  # sdl_ttf
  ttf-bitstream-vera
  ttf-dejavu
  ttf-fira-code
  ttf-jetbrains-mono
  ttf-jetbrains-mono-nerd
  ttf-liberation
  ttf-meslo-nerd
  ttf-opensans
  adobe-source-han-sans-cn-fonts
  adobe-source-han-sans-jp-fonts
  adobe-source-han-sans-kr-fonts
  otf-font-awesome
  powerline-fonts
  noto-fonts-emoji
  rofi-emoji
)

printf "\n%.0s" {1..2}  
echo -e "\e[35m
        ##############
         FONTS SCRIPT
        ##############
\e[0m"
printf "\n%.0s" {1..1} 


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_func.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_fonts.log"

for RPG in "${fonts[@]}"; do
	install_package_pacman "$RPG" 2>&1 | tee -a "$LOG"
done

# Microsoft fonts (include: Times new roman, calibri and the like)
install_package "ttf-ms-fonts" 2>&1 | tee -a  "$LOG" 
