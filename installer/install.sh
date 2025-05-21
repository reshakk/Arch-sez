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
OK="$(gum style --foreground 2 '[OK]')"
ERROR="$(gum style --foreground 1 '[ERROR]')"
NOTE="$(gum style --foreground 3 '[NOTE]')"
INFO="$(gum style --foreground 4 '[INFO]')"
RESET="$(tput sgr0)"

ERROR2="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE2="$(tput setaf 3)[NOTE]$(tput sgr0)"

# Log file
LOG="install-$(date +%d-%H%M%S).log"

# Create directory for Logs
mkdir -p Install-Logs

# Define directory where your scripts are located
script_directory="i-scripts"

# Check if running as root. If root, scripts will exit
if [[ $EUID -eq 0 ]]; then
    echo -e "${ERROR2} Don't use root privileges"
    exit 1
fi

# Check if gum is installed
if ! pacman -Q gum &> /dev/null; then
    echo -e "${ERROR2} gum is not installed. Installing now..."
    if sudo pacman -S --noconfirm gum >> "$LOG" 2>&1; then
        echo -e "${NOTE2} gum has been installed successfully."
    else
        echo -e "${ERROR2} Failed to install gum. Please install it manually."
        exit 1
    fi
fi

clear

# Welcome message
gum format --type markdown << EOM
# Arch Linux Installation Script
This script will guide you through installing essential packages and optional components for your Arch Linux system.
Please select the components you want to install in the next step.
EOM
sleep 2

# Check for PulseAudio
if pacman -Q pipewire &> /dev/null; then
    gum style --border normal --border-foreground 3 "${NOTE} PulseAudio is installed"
    PulseAudio="N"
else
    PulseAudio="Y"
fi

install_package() {
    local package="$1"
    if pacman -Q "$package" &> /dev/null; then
        gum style --border normal --border-foreground 3 "${NOTE} $package is already installed."
    else
        gum style --border normal --border-foreground 4 "${INFO} Installing $package..."
        gum spin --spinner dot --title "Installing $package..." -- \
            sudo pacman -S --noconfirm "$package" >> "$LOG" 2>&1
        if pacman -Q "$package" &> /dev/null; then
            gum style --border normal --border-foreground 4 "${INFO} $package has been installed successfully."
        else
            gum style --border double --border-foreground 1 "${ERROR} $package cannot be installed. Please install it manually."
            exit 1
        fi
    fi
}

# Install required packages
install_package "base-devel"
install_package "archlinux-keyring"
install_package "git"

# Install yay
if pacman -Q "yay" &> /dev/null; then
    gum style --border normal --border-foreground 3 "${NOTE} yay is already installed."
else
    gum style --border normal --border-foreground 4 "${INFO} Installing yay..."
    gum spin --spinner dot --title "Cloning yay from AUR..." -- \
        git clone https://aur.archlinux.org/yay.git >> "$LOG" 2>&1 || {gum style --border double --border-foreground 1 "${ERROR} Failed to clone yay from AUR";exit 1;}
    cd yay || {gum style --border double --border-foreground 1 "${ERROR} Failed to enter yay directory";exit 1;}
    gum spin --spinner dot --title "Building and installing yay..." -- \
        makepkg -si --noconfirm >> "$LOG" 2>&1 || {gum style --border double --border-foreground 1 "${ERROR} Failed to install yay from AUR";exit 1;}
    if pacman -Q "yay" &> /dev/null; then
        gum style --border normal --border-foreground 4 "${INFO} yay has been installed successfully."
        rm -rf yay || gum style --border double --border-foreground 1 "${ERROR} Failed to delete yay directories"
    else
        gum style --border double --border-foreground 1 "${ERROR} yay cannot be installed. Please install it manually."
        exit 1
    fi
fi

# Interactive package selection with gum choose
gum format --type markdown << EOM
## Select Optional Components
Use arrow keys to navigate, space to select, and Enter to confirm.
EOM
selected_options=$(gum choose --no-limit \
    "AMD-drivers: Install AMD drivers" \
    "Thunar: Install Thunar file manager" \
    "Fish: Install Fish shell" \
    "Flatpak: Install Flatpak packages (Lutris, Cpu-x, Flatseal, Mission-center, Nextcloud, Proton-Qt, Vesktop, Warehouse)" \
    "Cups and HP-drivers: Install printing support" \
    "SDDM: Install SDDM display manager" \
    "Dotfiles: Set up dotfiles")

# Parse selections into variables
amd="N"
thunar="N"
fish="N"
flatpak="N"
hprinter="N"
sddm="N"
dotf="N"

[[ "$selected_options" =~ "AMD-drivers" ]] && amd="Y"
[[ "$selected_options" =~ "Thunar" ]] && thunar="Y"
[[ "$selected_options" =~ "Fish" ]] && fish="Y"
[[ "$selected_options" =~ "Flatpak" ]] && flatpak="Y"
[[ "$selected_options" =~ "Cups and HP-drivers" ]] && hprinter="Y"
[[ "$selected_options" =~ "SDDM" ]] && sddm="Y"
[[ "$selected_options" =~ "Dotfiles" ]] && dotf="Y"

# Log user selections
gum style --border normal --border-foreground 4 "${INFO} Selected options:" >> "$LOG"
echo "$selected_options" >> "$LOG"

# Confirm selections before proceeding
gum format --type markdown << EOM
## Confirm Selections
You selected:
$(echo "$selected_options" | sed 's/^/- /')
EOM
if ! gum confirm "Proceed with these selections?"; then
    gum style --border double --border-foreground 1 "${ERROR} Installation aborted by user."
    exit 1
fi

execute_script() {
    local script="$1"
    local script_path="$script_directory/$script"
    
    if [[ -f "$script_path" ]]; then
        chmod +x "$script_path"
        if [[ -x "$script_path" ]]; then
            gum spin --spinner dot --title "Executing $script..." -- \
                env USE_PRESET="$user_preset" "$script_path" >> "$LOG" 2>&1
        else
            gum style --border double --border-foreground 1 "${ERROR} Failed to make script '$script' executable."
        fi
    else
        gum style --border double --border-foreground 1 "${ERROR} Script '$script' not found in '$script_directory'."
    fi
}

gum style --border double --border-foreground 4 "${INFO} Starting installation process..."

chmod +x i-scripts/* >> "$LOG" 2>&1
sleep 1

if [ "$PulseAudio" == "Y" ]; then
    execute_script "pipewire.sh"
fi

# Script with main packages
execute_script "00-pkgs.sh"
execute_script "fonts.sh"

[[ "$amd" == "Y" ]] && execute_script "amd.sh"
[[ "$thunar" == "Y" ]] && execute_script "thunar.sh"
[[ "$fish" == "Y" ]] && execute_script "fish.sh"
[[ "$flatpak" == "Y" ]] && execute_script "flatpak.sh"
[[ "$hprinter" == "Y" ]] && execute_script "printer.sh"
[[ "$sddm" == "Y" ]] && execute_script "sddm.sh"
[[ "$dotf" == "Y" ]] && execute_script "dotfiles.sh"

clear

# Execute final script
execute_script "01-check.sh"

# Installation summary
gum format --type markdown << EOM
# Installation Summary
- AMD Drivers: $amd
- Thunar: $thunar
- Fish: $fish
- Flatpak: $flatpak
- Printer Support: $hprinter
- SDDM: $sddm
- Dotfiles: $dotf
EOM

# Check if hyprland or hyprland-git is installed
if pacman -Q hyprland &> /dev/null || pacman -Q hyprland-git &> /dev/null; then
    gum format --type markdown << EOM
# Installation Complete
Hyprland is installed. However, some essential packages may not be installed. Check the logs in 'Install-Logs/' for details.

**It is highly recommended to reboot your system.**
EOM
    sleep 2
    if gum confirm "Would you like to reboot now?" --timeout 30s; then 
        gum style --border normal --border-foreground 4 "${INFO} Rebooting in 5 seconds..."
        sleep 5
        systemctl reboot
    else
        gum style --border normal --border-foreground 3 "${NOTE} Reboot skipped. Please reboot manually later."
    fi
else
    gum format --type markdown << EOM
# Installation Failed
Hyprland failed to install. Please check '01_check-time_installed.log' and other files in 'Install-Logs/' directory for details.
EOM
    exit 1
fi
