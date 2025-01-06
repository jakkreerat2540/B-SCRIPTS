#!/usr/bin/env bash
#
# A script to download, install, and configure Docker with some basic logging options.
# Compatible with most modern Linux distributions that use systemd (e.g., Ubuntu, Debian, CentOS, Fedora).
#
# Usage: sudo ./install_docker.sh

set -euo pipefail

###############################################################################
# Helper Functions
###############################################################################

# Print messages in color for better visibility
function info()    { echo -e "\e[34m[INFO]\e[0m $*"; }
function success() { echo -e "\e[32m[SUCCESS]\e[0m $*"; }
function warning() { echo -e "\e[33m[WARNING]\e[0m $*"; }
function error()   { echo -e "\e[31m[ERROR]\e[0m $*" >&2; }

# Exit if not running as root
function check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root or with sudo privileges."
        exit 1
    fi
}

# Check if a command/binary exists
function command_exists() {
    command -v "$@" >/dev/null 2>&1
}

# Check distribution (optional check to handle different distros)
function get_distribution() {
    # Parse /etc/os-release for distro name
    if [ -r /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        warning "/etc/os-release not found. Unable to detect distribution."
        echo "unknown"
    fi
}

###############################################################################
# Docker Functions
###############################################################################

#function download_docker() {
#    info "Downloading Docker installation script..."
#    if curl -fsSL https://get.docker.com -o get-docker.sh; then
#        chmod +x get-docker.sh
#        success "Docker installation script downloaded successfully."
#    else
#        error "Failed to download the Docker installation script. Please check your network connection or proxy settings."
#        exit 1
#    fi
#}

function download_docker() {
    info "Downloading Docker installation script..."
    if curl -fsSL https://get.docker.com -o get-docker.sh; then
        chmod +x get-docker.sh
        # Add AlmaLinux as recognized distribution
        sed -i 's/elif \[ "\$lsb_dist" = "centos" \]/elif [ "$lsb_dist" = "centos" ] || [ "$lsb_dist" = "almalinux" ]/g' get-docker.sh
        success "Docker installation script downloaded and modified successfully."
    else
        error "Failed to download the Docker installation script. Please check your network connection or proxy settings."
        exit 1
    fi
}

function install_docker() {
    info "Installing Docker..."
    # Run the Docker installation script
    ./get-docker.sh

    # Give the system a few seconds to register Docker
    sleep 5

    # Enable and start Docker (in case the script doesn't do it automatically)
    systemctl enable docker
    systemctl start docker

    # Check if Docker is running
    if systemctl is-active --quiet docker; then
        success "Docker service is active and running."
    else
        error "Docker is not running. Check logs or run 'systemctl status docker'."
        exit 1
    fi

    configure_docker
}

function configure_docker() {
    info "Configuring Docker logging options..."
    mkdir -p /etc/docker

    cat <<EOF >/etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}
EOF

    systemctl daemon-reload
    systemctl restart docker

    success "Docker logging configuration applied."
    docker --version
    docker info
}

###############################################################################
# Main
###############################################################################

function main() {
    check_root

    # Optional: detect distribution
    DISTRO=$(get_distribution)
    info "Detected distro: $DISTRO"

    # Check if Docker is already installed
    if command_exists docker; then
        success "Docker is already installed on this system."
        docker --version
        exit 0
    fi

    # Download and install Docker
    download_docker
    install_docker
}

main "$@"
