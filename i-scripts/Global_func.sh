#!/usr/bin/env bash

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
RESET="$(tput sgr0)"

set -e

if [ ! -d Install-Logs ]; then
	mkdir Install-Logs
fi

install_package_pacman() {
	if pacman -Q "$1" &>/dev/null; then
		echo "${OK} $1 is already installed"
	else
		echo "${NOTE} Installing $1"
		sudo pacman -S --noconfirm "$1" 2>&1 | tee -a "$LOG"
		if pacman -Q "$1" &>/dev/null; then
			echo "${OK} $1 was installed"
		else
			echo -e "${ERROR} $1 failed to install. Please check the $LOG."
			sleep 2s
			exit 1
		fi
	fi
}

install_package() {
	if yay -Q "$1" &>/dev/null; then
		echo "${OK} $1 is already installed"
	else
		echo "${NOTE} Installing $1"
		yay -S --noconfirm --needed "$1" 2>&1 | tee -a "$LOG"
		if yay -Q "$1" &>/dev/null; then
			echo "${OK} $1 was installed"
		else
			echo -e "${ERROR} $1 failed to install. Please check the $LOG."
			sleep 2s
			exit 1
		fi
	fi
}

uninstall_package() {
	if pacman -Q "$1" &>/dev/null; then
		echo "${NOTE} Uninstalling $1"
		sudo pacman -R --noconfirm "$1" 2>&1 | tee -a "$LOG"
		if pacman -Q "$1" &>/dev/null; then
			echo "${OK} $1 was uninstalling"
		else
			echo "${ERROR}  $1 failed to uninstall. Please check the $LOG."
			sleep 1s
			return 1
		fi
	else
		echo "${ERROR} Not found $1"
		sleep 1s
	fi
	return 0
}
