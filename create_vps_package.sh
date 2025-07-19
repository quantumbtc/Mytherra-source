#!/bin/bash

# VPS Deployment Package Creation Script
# This script creates a minimal package for running Mytherra node on VPS

echo "Creating VPS deployment package..."

# Create deployment directory
VPS_PACKAGE_DIR="mytherra-vps-package"
rm -rf $VPS_PACKAGE_DIR
mkdir -p $VPS_PACKAGE_DIR/bin
mkdir -p $VPS_PACKAGE_DIR/config
mkdir -p $VPS_PACKAGE_DIR/scripts

echo "Copying essential binaries..."
# Copy essential binaries
cp src/mytherrad $VPS_PACKAGE_DIR/bin/
cp src/mytherra-cli $VPS_PACKAGE_DIR/bin/
cp src/mytherra-tx $VPS_PACKAGE_DIR/bin/

echo "Creating VPS configuration..."
# Create VPS-specific mytherra.conf
cat > $VPS_PACKAGE_DIR/config/mytherra.conf << 'EOF'
# Mytherra VPS Node Configuration
# Network settings
listen=1
port=24155
rpcport=24156
rpcbind=127.0.0.1
rpcallowip=127.0.0.1

# Server mode
server=1
daemon=1

# Network discovery
discover=1
dnsseed=1
addnode=127.0.0.1:24155

# Logging
debug=1
printtoconsole=0

# Performance
maxconnections=125
dbcache=512

# Mining (disabled for VPS node)
gen=0

# Wallet (optional, can be disabled for pure node)
disablewallet=0
EOF

echo "Creating VPS startup scripts..."
# Create VPS startup script
cat > $VPS_PACKAGE_DIR/scripts/start_node.sh << 'EOF'
#!/bin/bash

# Mytherra VPS Node Startup Script

MYTHERRA_DIR="$HOME/.mytherra"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BIN_DIR="$SCRIPT_DIR/../bin"

echo "Starting Mytherra VPS Node..."

# Create data directory if it doesn't exist
mkdir -p "$MYTHERRA_DIR"

# Copy config if it doesn't exist
if [ ! -f "$MYTHERRA_DIR/mytherra.conf" ]; then
    cp "$SCRIPT_DIR/../config/mytherra.conf" "$MYTHERRA_DIR/"
    echo "Configuration copied to $MYTHERRA_DIR/mytherra.conf"
fi

# Start the daemon
echo "Starting mytherrad..."
"$BIN_DIR/mytherrad" -daemon -conf="$MYTHERRA_DIR/mytherra.conf"

# Wait a moment for startup
sleep 3

# Check if daemon is running
if pgrep -f mytherrad > /dev/null; then
    echo "Mytherra daemon started successfully!"
    echo "Use './scripts/status.sh' to check node status"
    echo "Use './scripts/stop_node.sh' to stop the node"
else
    echo "Failed to start Mytherra daemon!"
    exit 1
fi
EOF

# Create status check script
cat > $VPS_PACKAGE_DIR/scripts/status.sh << 'EOF'
#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BIN_DIR="$SCRIPT_DIR/../bin"

echo "=== Mytherra Node Status ==="
echo

# Check if daemon is running
if pgrep -f mytherrad > /dev/null; then
    echo "✓ Daemon is running"
    
    # Get blockchain info
    echo
    echo "=== Blockchain Info ==="
    "$BIN_DIR/mytherra-cli" -conf="$HOME/.mytherra/mytherra.conf" getblockchaininfo
    
    echo
    echo "=== Network Info ==="
    "$BIN_DIR/mytherra-cli" -conf="$HOME/.mytherra/mytherra.conf" getnetworkinfo
    
    echo
    echo "=== Peer Info ==="
    "$BIN_DIR/mytherra-cli" -conf="$HOME/.mytherra/mytherra.conf" getpeerinfo
else
    echo "✗ Daemon is not running"
fi
EOF

# Create stop script
cat > $VPS_PACKAGE_DIR/scripts/stop_node.sh << 'EOF'
#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BIN_DIR="$SCRIPT_DIR/../bin"

echo "Stopping Mytherra node..."

# Try graceful shutdown first
"$BIN_DIR/mytherra-cli" -conf="$HOME/.mytherra/mytherra.conf" stop 2>/dev/null

# Wait for graceful shutdown
sleep 5

# Force kill if still running
if pgrep -f mytherrad > /dev/null; then
    echo "Force stopping daemon..."
    pkill -f mytherrad
    sleep 2
fi

if ! pgrep -f mytherrad > /dev/null; then
    echo "Mytherra daemon stopped successfully!"
else
    echo "Failed to stop daemon!"
    exit 1
fi
EOF

# Create logs viewer script
cat > $VPS_PACKAGE_DIR/scripts/view_logs.sh << 'EOF'
#!/bin/bash

MYTHERRA_DIR="$HOME/.mytherra"

echo "=== Mytherra Debug Logs (last 50 lines) ==="
echo "Press Ctrl+C to exit"
echo

if [ -f "$MYTHERRA_DIR/debug.log" ]; then
    tail -f -n 50 "$MYTHERRA_DIR/debug.log"
else
    echo "No debug.log found in $MYTHERRA_DIR"
fi
EOF

# Create README for VPS
cat > $VPS_PACKAGE_DIR/README.md << 'EOF'
# Mytherra VPS Node Package

This package contains everything needed to run a Mytherra node on a VPS.

## Contents

- `bin/` - Compiled Mytherra binaries
  - `mytherrad` - Mytherra daemon
  - `mytherra-cli` - Command line interface
  - `mytherra-tx` - Transaction utility

- `config/` - Configuration files
  - `mytherra.conf` - Default node configuration

- `scripts/` - Management scripts
  - `start_node.sh` - Start the Mytherra node
  - `stop_node.sh` - Stop the Mytherra node
  - `status.sh` - Check node status and blockchain info
  - `view_logs.sh` - View node logs in real-time

## Quick Start

1. Upload this package to your VPS
2. Extract: `tar -xzf mytherra-vps-package.tar.gz`
3. Make scripts executable: `chmod +x scripts/*.sh`
4. Start the node: `./scripts/start_node.sh`
5. Check status: `./scripts/status.sh`

## Requirements

- Linux VPS with at least 1GB RAM
- Open ports: 24155 (P2P), 24156 (RPC - localhost only)
- At least 10GB free disk space

## Configuration

Edit `~/.mytherra/mytherra.conf` after first run to customize settings.

## Support

For support, check the debug logs with `./scripts/view_logs.sh`
EOF

# Make scripts executable
chmod +x $VPS_PACKAGE_DIR/scripts/*.sh

echo "Creating compressed package..."
tar -czf mytherra-vps-package.tar.gz $VPS_PACKAGE_DIR/

echo
echo "=== VPS Package Created Successfully! ==="
echo
echo "Package: mytherra-vps-package.tar.gz"
echo "Size: $(du -h mytherra-vps-package.tar.gz | cut -f1)"
echo
echo "Files to upload to VPS:"
echo "1. mytherra-vps-package.tar.gz (main package)"
echo
echo "Optional (for bootstrapping):"
echo "2. ~/.mytherra/blocks/ (blockchain data)"
echo "3. ~/.mytherra/chainstate/ (chain state)"
echo
echo "Upload command example:"
echo "scp mytherra-vps-package.tar.gz user@your-vps:/home/user/"
echo
echo "VPS setup commands:"
echo "tar -xzf mytherra-vps-package.tar.gz"
echo "cd mytherra-vps-package"
echo "chmod +x scripts/*.sh"
echo "./scripts/start_node.sh"
