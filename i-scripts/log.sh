#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

# Log file
LOG_DIR="Install-Logs"

# Output file for errors
ERROR_FILE="$LOG_DIR/errors.txt"

> "$ERROR_FILE"

# Find all log files and extract lines containing ERROR
find "$LOG_DIR" -type f -name "*.log" -exec grep "ERROR" {} + >> "$ERROR_FILE"

if pacman -Q python &> /dev/null; then
	python3 generate_report.py "$ERROR_FILE"
else
	printf "\n%.0s" {1..1}
	echo "You can check the summary information about the error in the $ERROR_FILE"
fi
