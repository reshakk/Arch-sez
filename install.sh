#!/usr/bin/env bash

# ██▀███  ▓█████   ██████  ██░ ██  ▄▄▄       ██ ▄█▀ ██ ▄█▀
#▓██ ▒ ██▒▓█   ▀ ▒██    ▒ ▓██░ ██▒▒████▄     ██▄█▒  ██▄█▒ 
#▓██ ░▄█ ▒▒███   ░ ▓██▄   ▒██▀▀██░▒██  ▀█▄  ▓███▄░ ▓███▄░ 
#▒██▀▀█▄  ▒▓█  ▄   ▒   ██▒░▓█ ░██ ░██▄▄▄▄██ ▓██ █▄ ▓██ █▄ 
#░██▓ ▒██▒░▒████▒▒██████▒▒░▓█▒░██▓ ▓█   ▓██▒▒██▒ █▄▒██▒ █▄
#░ ▒▓ ░▒▓░░░ ▒░ ░▒ ▒▓▒ ▒ ░ ▒ ░░▒░▒ ▒▒   ▓▒█░▒ ▒▒ ▓▒▒ ▒▒ ▓▒
#  ░▒ ░ ▒░ ░ ░  ░░ ░▒  ░ ░ ▒ ░▒░ ░  ▒   ▒▒ ░░ ░▒ ▒░░ ░▒ ▒░
#  ░░   ░    ░   ░  ░  ░   ░  ░░ ░  ░   ▒   ░ ░░ ░ ░ ░░ ░ 
#   ░        ░  ░      ░   ░  ░  ░      ░  ░░  ░   ░  ░   

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
RESET="$(tput sgr0)"

# Options for quick setting in scripts(Y\N). 
PRESET="N" # Don't need to choose option, just execute all scripts
UNE_PACKAGE="Y" # For unnecessary packages
VIS_PACKAGE="Y" # For visual packages

export "$PRESET"
export "$UNE_PACKAGE"
export "$VIS_PACKAGE"

# Log file
LOG="install-$(date +%d-%H%M%S).log"

# Create directory for Logs
mkdir -p Install-Logs

ORIGIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Define directory where your scripts are located
script_directory="i-scripts"

# Check if running as root. If root, scripts will exit
if [[ $EUID -eq 0 ]]; then
	echo "${ERROR} ERROR: Don't use root privileges"
	exit 1
fi

clear


install_package() {
    if pacman -Q "$1" &> /dev/null; then
        echo "${NOTE} $1 is already installed."
    else
        echo "${INFO} Installing $1..."
        if sudo pacman -S --noconfirm "$1"; then
            echo "${INFO} $1 has been installed successfully."
        else
            echo "${ERROR} ERROR: $1 cannot be installed. Please install it manually."
            exit 1
        fi
    fi
}

# Install required packages
install_package "base-devel"
install_package "archlinux-keyring"
install_package "git"


#Install yay
if pacman -Q "yay" &> /dev/null; then
	echo "${NOTE} yay is already installed."
else
	echo "${INFO} Installing yay..."
	git clone https://aur.archlinux.org/yay.git || { printf "%s - Failed to clone yay from AUR\n"; exit 1; }
	cd yay || { printf "%s - Failed to enter yay directory\n"; exit 1; }
	cd "$ORIGIN_DIR"
  	makepkg -si --noconfirm 2>&1 | tee -a "$LOG" || { printf "%s - Failed to install yay from AUR\n"; exit 1; }
	if pacman -Q "yay" &> /dev/null; then
		echo "${INFO} yay has been installed successfully."
        rm -rf yay || echo "${ERROR} Failed to delete yay directories"
	else
		echo "${ERROR} ERROR: yay cannot be installed. Please install it manually."
		exit 1
	fi
fi

ask_yes_no() {
    local prompt="$1"
    local var_name="$2"

    if [[ -n "${!var_name}" ]]; then
        echo "$prompt"
        [[ "${!var_name}" =~ ^[Yy]$ ]] && return 0 || return 1
    else
        eval "$var_name=''"
    fi

    while true; do
        read -p "$prompt (y/n): " choice
        case "$choice" in
            [Yy]*) eval "$var_name='Y'"; return 0 ;;
            [Nn]*) eval "$var_name='N'"; return 1 ;;
            *) echo "Please answer with y or n." ;;
        esac
    done
}

execute_script() {
    local script="$1"
    local script_path="$script_directory/$script"
    
    if [[ -f "$script_path" ]]; then
        chmod +x "$script_path"
        if [[ -x "$script_path" ]]; then
            env USE_PRESET="$user_preset" "$script_path"
        else
            echo "${ERROR} ERROR: Failed to make script '$script' executable."
	    sleep 3s
        fi
    else
        echo "${ERROR} ERROR: Script '$script' not found in '$script_directory'."
	sleep 3s
    fi
}

en_multilib() {
  sudo sed -i 's/^#\[multilib\]/[multilib]/' /etc/pacman.conf
  sudo sed -i '/^\[multilib\]$/ { n; s/^#//; }' /etc/pacman.conf
}

if [[ "$PRESET" == "Y" ]]; then
  software="Y"
  thunar="Y"
  fish="Y"
  flatpak="Y"
  hprinter="Y"
  sddm="Y"
  dotf="Y"
  vimp="Y"
  mult="Y"
else
  printf "\n"
  ask_yes_no "-Do you want AMD, Intell and Vmware drivers?" software
  printf "\n"
  ask_yes_no "-Do you want to download Thunar?" thunar
  printf "\n"
  ask_yes_no "-Do you want to download fish?" fish
  printf "\n"
  ask_yes_no "-Do you want to download packages for flatpak(Cpu-x, Flatseal, Filelight, Proton-Qt, Warehouse)?" flatpak
  printf "\n"
  ask_yes_no "-Do you want to download cups and hp-drivers?" hprinter
  printf "\n"
  ask_yes_no "-Do you want to download sddm?" sddm
  printf "\n"
  ask_yes_no "-Do you want to set dotfiles?" dotf
  printf "\n"
  ask_yes_no "-Do you want to install plugins for vim?" vimp
  printf "\n"
  ask_yes_no "-Do you want to enable multilib repository?" mult
  printf "\n"
fi

chmod +x i-scripts/*
sleep 1


execute_script "pipewire.sh"	
sleep 2s
#Script with main packages
execute_script "00-pkgs.sh"
sleep 2s
execute_script "fonts.sh"

[[ "$software" == "Y" ]] && execute_script "software.sh"
sleep 1s
[[ "$thunar" == "Y" ]] && execute_script "thunar.sh"
sleep 1s
[[ "$fish" == "Y" ]] && execute_script "fish.sh"
sleep 1s
[[ "$flatpak" == "Y" ]] && execute_script "flatpak.sh"	
sleep 1s
[[ "$hprinter" == "Y" ]] && execute_script "printer.sh"
sleep 1s
[[ "$sddm" == "Y" ]] && execute_script "sddm.sh"
sleep 1s
[[ "$dotf" == "Y" ]] && execute_script "dotfiles.sh"
sleep 2s
[[ "$vimp" == "Y" ]] && execute_script "vim.sh"
sleep 2s
[[ "$mult" == "Y" ]] && en_multilib
sleep 2s

clear

#Execute final script
execute_script "01-check.sh"

#Execute script for logs
execute_script "log.sh"

printf "\n%.0s" {1..1}

# Check if hyprland or hyprland-git is installed
if pacman -Q hyprland &> /dev/null || pacman -Q hyprland-git &> /dev/null; then
    printf "\n Hyprland is installed. However, some essential packages may not be installed Please see above!"
    printf "\n Also you can check all error in all-error.log..."
    sleep 3s
    printf "\n It is highly recommended to reboot your system.\n\n"

    # Prompt user to reboot
    read -rp "Would you like to reboot now? (y/n): " HYP

    # Check if the user answered 'y' or 'Y'
    if [[ "$HYP" =~ ^[Yy]$ ]]; then 
        systemctl reboot
    fi
else
    # Print error message if neither package is installed
    printf "\n Hyprland failed to install. Please check 01_check-time_installed.log and other files Install-Logs/ directory...\n\n"
    exit 1
fi
