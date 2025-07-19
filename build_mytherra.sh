#!/bin/bash

# Mytherra Build Script
echo "=== Building Mytherra ==="

# Prüfe ob Abhängigkeiten installiert sind
echo "Prüfe Build-Abhängigkeiten..."

# Install dependencies if needed
if ! command -v make &> /dev/null; then
    echo "Installing build dependencies..."
    sudo apt update
    sudo apt install -y build-essential libtool autotools-dev automake pkg-config bsdmainutils python3
fi

if ! command -v autoreconf &> /dev/null; then
    echo "Installing autotools..."
    sudo apt install -y autoconf
fi

# Bitcoin Core dependencies for Mytherra
echo "Installing Mytherra dependencies..."
sudo apt install -y \
    libssl-dev \
    libevent-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    libboost-test-dev \
    libboost-thread-dev \
    libminiupnpc-dev \
    libzmq3-dev \
    libqt5gui5 \
    libqt5core5a \
    libqt5dbus5 \
    qttools5-dev \
    qttools5-dev-tools \
    libprotobuf-dev \
    protobuf-compiler \
    libqrencode-dev

echo "Baue Mytherra..."

# Clean previous builds
make clean 2>/dev/null || true

# Generate configure script
if [ ! -f "configure" ]; then
    echo "Generating configure script..."
    ./autogen.sh
fi

# Configure build
echo "Configuring build..."
./configure \
    --enable-wallet \
    --with-gui=qt5 \
    --enable-upnp-default \
    --enable-zmq

# Build
echo "Compiling Mytherra..."
make -j$(nproc)

echo "Build completed!"
echo "Binaries are available in src/"
echo "- mytherrad: Core daemon"
echo "- mytherra-cli: Command line interface" 
echo "- mytherra-qt: GUI wallet"
