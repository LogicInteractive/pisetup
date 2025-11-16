#!/bin/bash

# Automated Haxe 4.3.7 installation script for Raspberry Pi
# Based on CompleteHaxeLimeInstall_Menu_RPi.sh option 2
#
# This script installs Haxe 4.3.7 from the Bookworm Docker image and handles
# library compatibility for newer Debian versions (Trixie/13+) by creating
# symlinks for mbedtls libraries (libmbedtls14 -> libmbedtls21, etc.)

set -e

DEFAULTTAGNAME="4.3.7-bookworm"
DOCKER='/usr/bin/docker'

echo "=============================================="
echo "Installing Haxe 4.3.7 from Docker"
echo "=============================================="

# Check if Docker is installed
if ! test -f "$DOCKER"; then
    echo "ERROR: Docker is not installed. Please install Docker first."
    exit 1
fi

echo "Docker found: $(docker -v)"

# Check if Haxe is already installed
if test -f "/usr/local/bin/haxe"; then
    HAXEVERSION=$(haxe --version 2>&1 || echo "unknown")
    echo "WARNING: Haxe $HAXEVERSION is already installed"
    echo "Proceeding with installation (will overwrite)..."
fi

# Create directories
mkdir -p ./docker_haxe/
sudo mkdir -p /usr/local/share/haxe/

# Pull and run Docker container
echo "Pulling Haxe Docker image: ${DEFAULTTAGNAME}"
docker run haxe:${DEFAULTTAGNAME}

# Get the container ID
CONTAINERID=$(docker ps -aq --latest)
echo "Container ID: $CONTAINERID"

# Copy files from container
echo "Copying Haxe binaries from container..."
docker cp $CONTAINERID:/usr/local/bin/haxe ./docker_haxe/
docker cp $CONTAINERID:/usr/local/bin/haxelib ./docker_haxe/
docker cp $CONTAINERID:/usr/local/share/haxe/std ./docker_haxe/

sleep 2

# Install to system
echo "Installing Haxe to /usr/local/bin/..."
cd docker_haxe
sudo cp haxe /usr/local/bin/
sudo cp haxelib /usr/local/bin/
sudo cp -R std /usr/local/share/haxe/

# Add HAXE_STD_PATH to bashrc if not already there
if [ $(grep 'export HAXE_STD_PATH' ~/.bashrc | wc -l) -eq 0 ]; then
    echo "Adding HAXE_STD_PATH to ~/.bashrc"
    echo -e "\nexport HAXE_STD_PATH=\"/usr/local/share/haxe/std\"" >> ~/.bashrc
fi

# Install neko if not already installed
if test -f /usr/bin/neko; then
    echo "Neko is already installed"
else
    echo "Installing neko..."
    sudo apt install -y neko
fi

# Fix library dependencies for Debian Trixie/Bookworm compatibility
echo "Checking mbedtls library dependencies..."
if [ ! -f /usr/lib/aarch64-linux-gnu/libmbedtls.so.14 ]; then
    echo "Creating symlink for libmbedtls.so.14..."
    sudo ln -sf /usr/lib/aarch64-linux-gnu/libmbedtls.so.21 /usr/lib/aarch64-linux-gnu/libmbedtls.so.14
fi
if [ ! -f /usr/lib/aarch64-linux-gnu/libmbedx509.so.1 ]; then
    echo "Creating symlink for libmbedx509.so.1..."
    sudo ln -sf /usr/lib/aarch64-linux-gnu/libmbedx509.so.7 /usr/lib/aarch64-linux-gnu/libmbedx509.so.1
fi
if [ ! -f /usr/lib/aarch64-linux-gnu/libmbedcrypto.so.7 ]; then
    echo "Creating symlink for libmbedcrypto.so.7..."
    sudo ln -sf /usr/lib/aarch64-linux-gnu/libmbedcrypto.so.16 /usr/lib/aarch64-linux-gnu/libmbedcrypto.so.7
fi

# Setup haxelib
echo "Setting up haxelib..."
export HAXE_STD_PATH="/usr/local/share/haxe/std"
sudo mkdir -p /usr/lib/haxe/lib
sudo chown $USER:$USER /usr/lib/haxe/lib
echo "/usr/lib/haxe/lib" | haxelib setup
haxelib --global update haxelib

# Create archive for future use
cd ..
HAXEVERSION=$(haxe --version 2>&1)
echo "Creating haxe-binaries-$HAXEVERSION.tgz archive for future use..."
tar zcf haxe-binaries-$HAXEVERSION.tgz ./docker_haxe

echo "=============================================="
echo "Haxe $HAXEVERSION is installed successfully!"
echo "=============================================="
echo "Please run: source ~/.bashrc"
echo "Or restart your terminal to use Haxe."
