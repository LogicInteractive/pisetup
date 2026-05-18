#!/bin/bash

# Automated Haxe 4.3.7 installation script for Raspberry Pi
#
# Trixie (Debian 13+): installs from prebuilt haxe-binaries437_trixie.tgz,
#   a native Trixie build that links directly against libmbedtls.so.21 /
#   libmbedx509.so.7 / libmbedcrypto.so.16 and libneko.so.2. No Docker
#   pull and no mbedtls compatibility symlinks needed.
#
# Bookworm and earlier: pulls binaries from the haxe:4.3.7-bookworm Docker
#   image and creates mbedtls symlinks (libmbedtls14 -> libmbedtls21, etc.)
#   so the Bookworm-built binaries also run on Trixie hosts.

set -e

# Detect Debian codename
CODENAME=""
if [ -r /etc/os-release ]; then
    . /etc/os-release
    CODENAME="${VERSION_CODENAME:-}"
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TRIXIE_TARBALL="haxe-binaries437_trixie.tgz"

install_from_trixie_tarball() {
    echo "=============================================="
    echo "Installing Haxe 4.3.7 (Trixie native build)"
    echo "=============================================="

    if test -f "/usr/local/bin/haxe"; then
        HAXEVERSION=$(haxe --version 2>&1 || echo "unknown")
        echo "WARNING: Haxe $HAXEVERSION is already installed"
        echo "Proceeding with installation (will overwrite)..."
    fi

    if [ -f "$SCRIPT_DIR/$TRIXIE_TARBALL" ]; then
        TARBALL="$SCRIPT_DIR/$TRIXIE_TARBALL"
    elif [ -f "./$TRIXIE_TARBALL" ]; then
        TARBALL="./$TRIXIE_TARBALL"
    else
        echo "Fetching $TRIXIE_TARBALL from GitHub..."
        curl -fL -o "./$TRIXIE_TARBALL" \
            "https://github.com/LogicInteractive/pisetup/raw/main/$TRIXIE_TARBALL"
        TARBALL="./$TRIXIE_TARBALL"
    fi

    echo "Extracting $TARBALL..."
    rm -rf ./docker_haxe
    tar xzf "$TARBALL"

    echo "Installing Haxe to /usr/local/bin/..."
    sudo mkdir -p /usr/local/share/haxe/
    sudo cp ./docker_haxe/haxe /usr/local/bin/
    sudo cp ./docker_haxe/haxelib /usr/local/bin/
    sudo cp -R ./docker_haxe/std /usr/local/share/haxe/

    if test -f /usr/bin/neko; then
        echo "Neko is already installed"
    else
        echo "Installing neko..."
        sudo apt install -y neko
    fi
}

install_from_docker() {
    DEFAULTTAGNAME="4.3.7-bookworm"
    DOCKER='/usr/bin/docker'

    echo "=============================================="
    echo "Installing Haxe 4.3.7 from Docker"
    echo "=============================================="

    if ! test -f "$DOCKER"; then
        echo "ERROR: Docker is not installed. Please install Docker first."
        exit 1
    fi

    echo "Docker found: $(docker -v)"

    if test -f "/usr/local/bin/haxe"; then
        HAXEVERSION=$(haxe --version 2>&1 || echo "unknown")
        echo "WARNING: Haxe $HAXEVERSION is already installed"
        echo "Proceeding with installation (will overwrite)..."
    fi

    mkdir -p ./docker_haxe/
    sudo mkdir -p /usr/local/share/haxe/

    echo "Pulling Haxe Docker image: ${DEFAULTTAGNAME}"
    docker run haxe:${DEFAULTTAGNAME}

    CONTAINERID=$(docker ps -aq --latest)
    echo "Container ID: $CONTAINERID"

    echo "Copying Haxe binaries from container..."
    docker cp $CONTAINERID:/usr/local/bin/haxe ./docker_haxe/
    docker cp $CONTAINERID:/usr/local/bin/haxelib ./docker_haxe/
    docker cp $CONTAINERID:/usr/local/share/haxe/std ./docker_haxe/

    sleep 2

    echo "Installing Haxe to /usr/local/bin/..."
    cd docker_haxe
    sudo cp haxe /usr/local/bin/
    sudo cp haxelib /usr/local/bin/
    sudo cp -R std /usr/local/share/haxe/
    cd ..

    if test -f /usr/bin/neko; then
        echo "Neko is already installed"
    else
        echo "Installing neko..."
        sudo apt install -y neko
    fi

    # mbedtls symlinks for Bookworm-built binaries on Trixie/13+ hosts
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
}

case "$CODENAME" in
    trixie)
        install_from_trixie_tarball
        ;;
    bookworm|bullseye|"")
        install_from_docker
        ;;
    *)
        echo "Unknown Debian codename '$CODENAME', defaulting to Docker path"
        install_from_docker
        ;;
esac

# Add HAXE_STD_PATH to bashrc if not already there
if [ $(grep 'export HAXE_STD_PATH' ~/.bashrc | wc -l) -eq 0 ]; then
    echo "Adding HAXE_STD_PATH to ~/.bashrc"
    echo -e "\nexport HAXE_STD_PATH=\"/usr/local/share/haxe/std\"" >> ~/.bashrc
fi

# Setup haxelib
echo "Setting up haxelib..."
export HAXE_STD_PATH="/usr/local/share/haxe/std"
sudo mkdir -p /usr/lib/haxe/lib
sudo chown $USER:$USER /usr/lib/haxe/lib
echo "/usr/lib/haxe/lib" | haxelib setup
haxelib --global update haxelib

# Create archive for future use (only if docker_haxe/ is local, i.e. Docker path)
HAXEVERSION=$(haxe --version 2>&1)
if [ -d docker_haxe ] && [ "$CODENAME" != "trixie" ]; then
    echo "Creating haxe-binaries-$HAXEVERSION.tgz archive for future use..."
    tar zcf "haxe-binaries-$HAXEVERSION.tgz" ./docker_haxe
fi

echo "=============================================="
echo "Haxe $HAXEVERSION is installed successfully!"
echo "=============================================="
echo "Please run: source ~/.bashrc"
echo "Or restart your terminal to use Haxe."
