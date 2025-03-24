# Metasploit Environment Setup Script

This Bash script automates the installation and configuration of the Metasploit Framework in a Linux environment. It ensures all required packages are installed, sets up PostgreSQL, creates a non-root user, and optionally launches Metasploit with a new or default workspace.

## 🔧 Features
- Installs: `postgresql`, `metasploit-framework`, and other required tools
- Starts & enables PostgreSQL service
- Initializes the Metasploit database
- Creates a non-root user (e.g., `metasploituser`)
- Optionally creates and activates a named workspace in `msfconsole`

## 🚀 Usage

```bash
chmod +x setup_metasploit_env.sh
./setup_metasploit_env.sh
