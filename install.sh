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
available_scripts=()
if [ -f "wealthfetch.sh" ]; then
    available_scripts+=("wealthfetch.sh")
fi

# If no local files found, prompt to download
if [ ${#available_scripts[@]} -eq 0 ]; then
    echo "No brokefetch scripts found in the current directory."
    echo "Downloading the normal version..."
            if curl -sSL "$NORMAL_URL" -o "$temp_dir/wealthfetch.sh"; then
                source_file="$temp_dir/wealthfetch.sh"
                script_to_install="wealthfetch.sh"
                downloaded=1
            else
                    echo "Error: Failed to download the normal version. Exiting."
                    rm -r "$temp_dir"
                    exit 1
            fi

# If local files were found, prompt the user to choose
elif [ ${#available_scripts[@]} -eq 1 ]; then
    source_file="${available_scripts[0]}"
    script_to_install="${available_scripts[0]}"
    echo "Found '${source_file}'. This script will be installed."
else
    echo "Error: Found multiple scripts with the name 'wealthfetch.sh'."
    echo "Please remove or rename the extra files and try again."
    exit 1
fi

# Exit if no source file was determined (e.g., download failed or user quit)
if [ -z "$source_file" ]; then
    echo "Error: Could not determine a source file for installation."
    rm -rf "$temp_dir"
    exit 1
fi

# --- Step 2: Ask the user for the installation path ---
echo "Where would you like to install the 'brokefetch' script?"

install_path=""
use_sudo="false"

select install_choice in "/usr/bin" "$HOME/.local/bin" "Quit"; do
    case $install_choice in
        "/usr/bin" )
            install_path="/usr/bin/wealthfetch"
            use_sudo="true"
            echo "Installing to /usr/bin. You will be prompted for your password."
            break
            ;;
        "$HOME/.local/bin" )
            install_path="$HOME/.local/bin/wealthfetch"
            echo "Installing to ~/.local/bin."
            break
            ;;
        "Quit" )
            echo "Installation canceled."
            if [ $downloaded -eq 1 ]; then rm -rf "$temp_dir"; fi
            exit 0
            ;;
        * )
            echo "Invalid choice. Please select 1, 2, or 3."
            ;;
    esac
done

install_dir=$(dirname "$install_path")

# --- Step 3: Check for existing installation and prompt for overwrite/remove ---
if [ -f "$install_path" ]; then
    echo "An existing 'brokefetch' script was found at $install_path."
    read -p "Do you want to overwrite it? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation canceled by user."
        if [ $downloaded -eq 1 ]; then rm -rf "$temp_dir"; fi
        exit 0
    fi
fi

# --- Step 4: Perform the installation ---
echo "Installing '$script_to_install' to '$install_path'..."

# Create the directory if it doesn't exist
if [ "$use_sudo" = "true" ]; then
    sudo mkdir -p "$install_dir"
else
    mkdir -p "$install_dir"
fi

# Copy the chosen file
if [ "$use_sudo" = "true" ]; then
    sudo cp "$source_file" "$install_path"
else
    cp "$source_file" "$install_path"
fi

# Make the new file executable
if [ "$use_sudo" = "true" ]; then
    sudo chmod +x "$install_path"
else
    chmod +x "$install_path"
fi

# --- Step 6: Final success message and cleanup ---
echo "Success! '$script_to_install' is now installed as 'wealthfetch'."

if [ "$use_sudo" != "true" ]; then
    echo "You may need to add '$HOME/.local/bin' to your PATH to run it from any directory."
fi

# Clean up temporary downloaded file and cloned repository
if [ $downloaded -eq 1 ]; then
    echo "Cleaning up temporary files..."
    rm -rf "$temp_dir"
fi

exit 0


#finish later