#!/bin/bash

# This script interactively installs wealthfetch

# --- Best practice for robust scripts: Exit immediately on errors ---
set -e

# --- Function to check for curl ---
check_curl() {
    if ! command -v curl &> /dev/null; then
        echo "Error: 'curl' is not installed. Please install it to download the script."
        echo "On Debian/Ubuntu: sudo apt-get install curl"
        echo "On Fedora/CentOS: sudo dnf install curl"
        echo "On Arch Linux: sudo pacman -S curl"
        exit 1
    fi
}

# --- Function to check for git ---
check_git() {
    if ! command -v git &> /dev/null; then
        echo "Error: 'git' is not installed. Please install it to download the logos."
        echo "On Debian/Ubuntu: sudo apt-get install git"
        echo "On Fedora/CentOS: sudo dnf install git"
        echo "On Arch Linux: sudo pacman -S git"
        exit 1
    fi
}

# --- Define download URLs ---
# These URLs should point to the raw files in your GitHub repository.
NORMAL_URL="https://raw.githubusercontent.com/Szerwigi1410/wealthfetch/refs/heads/main/wealthfetch.sh"

# --- Main script execution starts here ---

# Check for necessary tools first
check_curl

# --- Step 1: Identify and/or download the source file ---
source_file=""
downloaded=0
temp_dir=$(mktemp -d)
script_to_install=""

# Check for existing local files
#finish later