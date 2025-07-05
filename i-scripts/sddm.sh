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

printf "\n%.0s" {1..2}
echo -e "\e[35m
        #############
         SDDM SCRIPT
        #############
\e[0m"
printf "\n%.0s" {1..1}

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "Failed to change directory to $PARENT_DIR"; exit 1; }

source "$(dirname "$(readlink -f "$0")")/Global_func.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_sddm.log"


# Install SDDM and SDDM theme
printf "${NOTE} Installing sddm and dependencies........\n"
  for package in "${sddm[@]}"; do
  install_package "$package" "$LOG"
  done 

printf "\n%.0s" {1..1}

# Check if other login managers installed and disabling its service before enabling sddm
for login_manager in "${login[@]}"; do
  if pacman -Qs "$login_manager" > /dev/null 2>&1; then
    sudo systemctl disable "$login_manager.service" 2>&1 | tee -a "$LOG" 
    echo "$login_manager disabled." 2>&1 | tee -a "$LOG"
  fi
done

# Double check with systemctl
for manager in "${login[@]}"; do
  if systemctl is-active --quiet "$manager" > /dev/null 2>&1; then
    echo "$manager is active, disabling it..." 2>&1 | tee -a "$LOG"
    sudo systemctl disable "$manager" --now 2>&1 | tee -a "$LOG"
  fi
done

printf "\n%.0s" {1..1}
printf "${INFO} Activating sddm service........\n"
sudo systemctl enable sddm

wayland_sessions_dir=/usr/share/wayland-sessions
[ ! -d "$wayland_sessions_dir" ] && { printf "$wayland_sessions_dir not found, creating...\n"; sudo mkdir "$wayland_sessions_dir" 2>&1 | tee -a "$LOG"; }

printf "\n%.0s" {1..2}
printf "${INFO} Copy doftiles for sddm........\n"

if git clone --depth 1 https://github.com/reshakk/sddmez.git; then
	cd sddmez
	sudo mkdir -p /etc/sddm.conf.d
	sudo mv sddmez.conf "/etc/sddm.conf.d/" 2>&1 | tee -a "../$LOG"

	if [ -d "/usr/share/sddm/themes" ]; then
		sudo mv simple-sddm-2 "/usr/share/sddm/themes/" 2>&1 | tee -a "../$LOG"
	else
		echo -e "${ERROR}Directory for sddm-themes doesn't exist. Check are installed sddm or not." 2>&1 | tee -a "../$LOG"
		sleep 2s
	fi
else
	echo -e "${ERROR} Failed to download sddm-themes." 2>&1 | tee -a "../$LOG"
	sleep 2s
	exit 1
fi


printf "\n%.0s" {1..4}
printf "Sddm and theme  is now Loaded & Ready!"
sleep 4s

