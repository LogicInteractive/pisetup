# Haxe setup for Raspberry Pi

## Quick Start (Recommended)

For a fully automated installation of Haxe 4.3.7:

```bash
./install_haxe_437.sh
```

This script auto-detects the Debian release and picks the right install path:
- **Trixie (Debian 13+)**: installs from prebuilt `haxe-binaries437_trixie.tgz`, a native Trixie build linked directly against `libmbedtls.so.21`. No Docker, no compatibility symlinks.
- **Bookworm and earlier**: pulls binaries from the `haxe:4.3.7-bookworm` Docker image and creates mbedtls compatibility symlinks so the Bookworm-built binaries also run on Trixie.
- Sets up haxelib and (on the Docker path) creates a binary archive for future use.

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

## Debian Trixie Support

On Trixie (Debian 13+) the installer uses `haxe-binaries437_trixie.tgz` — a native Trixie build whose binaries link directly against Trixie's `libmbedtls.so.21`, `libmbedx509.so.7`, `libmbedcrypto.so.16`, and `libneko.so.2`. No symlinks are created and Docker is not required.

On Bookworm and earlier, the script keeps the original behavior: it pulls Haxe from the `haxe:4.3.7-bookworm` Docker image, then creates compatibility symlinks so the same binaries also work if the host has been upgraded to Trixie:
- `libmbedtls.so.14` → `libmbedtls.so.21`
- `libmbedx509.so.1` → `libmbedx509.so.7`
- `libmbedcrypto.so.7` → `libmbedcrypto.so.16`

## Available Binary Archives

Pre-built Haxe binaries are included for faster installation:
- `haxe-binaries437_trixie.tgz` - Haxe 4.3.7 (Trixie native)
- `haxe-binaries437_bookworm.tgz` - Haxe 4.3.7 (Bookworm; also works on Trixie via symlinks)
- `haxe-binaries431.tgz` - Haxe 4.3.1
- `haxe-binaries425_bullseye.tgz` - Haxe 4.2.5 (Bullseye)
- `haxe-binaries423.tgz` - Haxe 4.2.3
- `haxe-binaries422.tgz` - Haxe 4.2.2
- `haxe-binaries421.tgz` - Haxe 4.2.1
- `haxe-binaries415.tgz` - Haxe 4.1.5
