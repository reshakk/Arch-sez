#!/usr/bin/env bash

# Package to uninstall
unins=(
	dunst
	htop
	dolphin
	wofi
  rofi
	nano
	grim
)

Extra=(
	#graphite-gtk-theme
)

# Unnecessary packages
une_package=(
  steam
  discord
  gedit
  obsidian
  mpv
  mpv-mpris 
  atril
  qbittorrent
  nextcloud-client
  gnome-keyring # Save autification for nextcloud
  wine
  mission-center
  qalculate-gtk
  btop
  libreoffice-still 
  #code
  npm
  aichat
  dotnet-sdk-7.0
  neovim
  slurp
  hyprpicker
  swww
  swaybg
  nwg-look
  python-pywal
  gnome-themes-extra # For nwg
  papirus-icon-theme
)

# Importen package for Hyprland
main_package=(	
  vim
  cliphist
  kitty
  shotwell
  pavucontrol
  playerctl
  wl-clipboard	
  rofi-wayland
  swaync
  hypridle
  waybar
  hyprlock
  hyprshot
  hyprland-qtutils
  qt6-wayland
  qt5-wayland
  xdg-desktop-portal-hyprland
  xorg-xwayland
  xdg-utils
  meson
  cmake
  cpio
)


# Standart command for terminal
stnd_com=(
  less
  git
  zip
  unzip
  rsync
  cron
  curl
  man
  wget	
  #nmap
  tmux
  udisks2
  smartmontools
  xorg-xhost
)

printf "\n%.0s" {1..2}  
echo -e "\e[35m
        ###############
         MAIN PACKAGES
        ###############
\e[0m"
printf "\n%.0s" {1..1} 


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_func.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprpkg.log"

# Main packages
for RPG in "${main_package[@]}" "${stnd_com[@]}" "${une_package[@]}" ;  do
  install_package_pacman "$RPG" 2>&1 | tee -a "$LOG"
done

# Extra packages
for RPG in "${Extra[@]}"; do
	install_package "$RPG" 2>&1 | tee -a "$LOG"
done

# uninstalling conflicting packages
# Initialize a variable to track overall errors
overall_failed=0

for RPG in "${unins[@]}"; do
  uninstall_package "$RPG" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    # Track if any uninstallation failed
    overall_failed=1
  fi
done

if [ $overall_failed -ne 0 ]; then
  echo -e "${ERROR} Some packages failed to uninstall. Please check the log."
fi

sleep 2s

clear
