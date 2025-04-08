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


# Log file
LOG="install-$(date +%d-%H%M%S).log"

# Create directory for Logs
mkdir -p Install-Logs

# Define directory where your scripts are located
script_directory="i-scripts"

# Check if running as root. If root, scripts will exit
if [[ $EUID -eq 0 ]]; then
	echo "${ERROR} ERROR: Don't use root privileges"
	exit 1
fi

clear

if pacman -Qq | grep -qw '^pipewire$'; then
	echo "${NOTE} PulseAudio is installed"
	PulseAudio="N"
else
	PulseAudio="Y"
fi

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
        fi
    else
        echo "${ERROR} ERROR: Script '$script' not found in '$script_directory'."
    fi
}

printf "\n"
ask_yes_no "-Do you want AMD-drivers?" amd
printf "\n"
ask_yes_no "-Do you want to download Thunar?" thunar
printf "\n"
ask_yes_no "-Do you want to download fish?" fish
printf "\n"
ask_yes_no "-Do you want to download packages for flatpak(Bottles, Cpu-x, Flatseal, Mission-center, Nextcloud, Proton-Qt, Vesktop, Warehouse)?" flatpak
printf "\n"
ask_yes_no "-Do you want to download cups and hp-drivers?" hprinter
printf "\n"
ask_yes_no "-Do you want to download sddm?" sddm
printf "\n"
ask_yes_no "-Do you want to set dotfiles?" dotf
printf "\n"

chmod +x i-scripts/*
sleep 1

if [ "$PulseAudio" == "Y" ]; then
       execute_script "pipewire.sh"	
fi

#Script with main packages
execute_script "00-pkgs.sh"
execute_script "fonts.sh"

[[ "$amd" == "Y" ]] && execute_script "amd.sh"
[[ "$thunar" == "Y" ]] && execute_script "thunar.sh"
[[ "$fish" == "Y" ]] && execute_script "fish.sh"
[[ "$flatpaks" == "Y" ]] && execute_script "flatpak.sh"	
[[ "$hprinter" == "Y" ]] && execute_script "printer.sh"
[[ "$sddm" == "Y" ]] && execute_script "sddm.sh"
[[ "$dotf" == "Y" ]] && execute_script "dotfiles.sh"

clear

#Execute final script
execute_script "01-check.sh"

printf "\n%.0s" {1..1}

# Check if hyprland or hyprland-git is installed
if pacman -Q hyprland &> /dev/null || pacman -Q hyprland-git &> /dev/null; then
    printf "\n Hyprland is installed. However, some essential packages may not be installed Please see above!"
    sleep 2
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
