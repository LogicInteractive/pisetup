# Haxe setup for Raspberry Pi

## Quick Start (Recommended)

For a fully automated installation of Haxe 4.3.7:

```bash
./install_haxe_437.sh
```

This script:
- Installs Haxe 4.3.7 from Docker (Bookworm image)
- Automatically handles library compatibility for Debian Trixie/Bookworm
- Sets up haxelib and creates binary archive for future use

## Interactive Menu Installation

For more options, use the interactive menu:

```bash
./CompleteHaxeLimeInstall_Menu_RPi.sh
```

## Features

- Install Docker (required for Haxe installation)
- Install Haxe 4.3.7 (latest stable) from Docker
- Install older Haxe versions from Docker
- Install Haxe from archived binaries
- Enable Hxcpp Compile Cache (Experimental)

## Debian Trixie Compatibility

For Debian Trixie (13) and newer, the `install_haxe_437.sh` script automatically creates symlinks for mbedtls library compatibility:
- `libmbedtls.so.14` → `libmbedtls.so.21`
- `libmbedx509.so.1` → `libmbedx509.so.7`
- `libmbedcrypto.so.7` → `libmbedcrypto.so.16`

## Available Binary Archives

Pre-built Haxe binaries are included for faster installation:
- `haxe-binaries437_bookworm.tgz` - Haxe 4.3.7 (Bookworm/Trixie)
- `haxe-binaries431.tgz` - Haxe 4.3.1
- `haxe-binaries425_bullseye.tgz` - Haxe 4.2.5 (Bullseye)
- `haxe-binaries423.tgz` - Haxe 4.2.3
- `haxe-binaries422.tgz` - Haxe 4.2.2
- `haxe-binaries421.tgz` - Haxe 4.2.1
- `haxe-binaries415.tgz` - Haxe 4.1.5
