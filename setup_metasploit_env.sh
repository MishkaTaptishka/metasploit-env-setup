#!/bin/bash

# Function to install missing packages
install_missing_tools() {
    echo "[*] Updating package list and installing required tools..."
    sudo apt update
    sudo apt install -y postgresql postgresql-contrib metasploit-framework curl wget nano
}

# Check if PostgreSQL is installed
if ! command -v psql &>/dev/null; then
    echo "[!] PostgreSQL is not installed. Installing..."
    install_missing_tools
else
    echo "[*] PostgreSQL is installed: $(psql --version)"
fi

# Check if Metasploit is installed
if ! command -v msfconsole &>/dev/null; then
    echo "[!] Metasploit Framework is not installed. Installing..."
    install_missing_tools
else
    echo "[*] Metasploit Framework is installed: $(msfconsole --version)"
fi

# Verify PostgreSQL service
echo "[*] Ensuring PostgreSQL service is running..."
sudo systemctl enable postgresql
sudo systemctl start postgresql
sudo systemctl status postgresql --no-pager

# Create a new non-root user for Metasploit (if not already created)
read -p "Enter the username for the new non-root user (default: metasploituser): " username
username=${username:-metasploituser}

if id "$username" &>/dev/null; then
    echo "[*] User '$username' already exists."
else
    echo "[*] Creating a new user: $username"
    sudo adduser "$username"
    sudo usermod -aG sudo "$username"
fi

# Initialize the Metasploit database as root
echo "[*] Initializing Metasploit database as root..."
sudo msfdb init

# Ask whether to create a new workspace or use default
read -p "Do you want to create a new workspace? (yes/no) [default: no]: " create_workspace
create_workspace=${create_workspace:-no}

if [[ "$create_workspace" == "yes" ]]; then
    # Prompt for workspace name
    read -p "Enter the name of the new workspace: " workspace_name

    # Switch to the non-root user and create/activate the workspace
    echo "[*] Switching to user: $username to launch msfconsole..."
    su - "$username" -c "
        echo '[*] Creating and activating workspace $workspace_name...'
        msfconsole -q -x 'workspace -a $workspace_name; workspace $workspace_name; db_status;'
    "
else
    # Use the default workspace
    echo "[*] Using default workspace..."
    su - "$username" -c "
        msfconsole -q -x 'workspace default; db_status;'
    "
fi
