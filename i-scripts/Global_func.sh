#!/usr/bin/env bash

set -e

if [ ! -d Install-Logs ]; then
	mkdir Install-Logs
fi

install_package_pacman() {
	if pacman -Q "$1" &>/dev/null; then
		echo "$1 is already installed"
	else
		echo "Installing $1"
		sudo pacman -S --noconfirm "$1" 2>&1 | tee -a "$LOG"
		if pacman -Q "$1" &>/dev/null; then
			echo "$1 was installed"
		else
			echo -e "$1 failed to install. Please check the $LOG."
			exit 1
		fi
	fi
}

install_package() {
	if yay -Q "$1" &>/dev/null; then
		echo "$1 is already installed"
	else
		echo "Installing $1"
		yay -S --noconfirm --needed "$1" 2>&1 | tee -a "$LOG"
		if yay -Q "$1" &>/dev/null; then
			echo "$1 was installed"
		else
			echo -e "$1 failed to install. Please check the $LOG."
			exit 1
		fi
	fi
}

uninstall_package() {
	if pacman -Q "$1" &>/dev/null; then
		echo "Uninstalling $1"
		sudo pacman -R --noconfirm "$1" 2>&1 | tee -a "$LOG"
		if pacman -Q "$1" &>/dev/null; then
			echo "$1 was uninstalling"
		else
			echo "$1 failed to uninstall. Please check the $LOG."
			return 1
		fi
	else
		echo "Not found $1"
	fi
	return 0
}
