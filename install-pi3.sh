#!/bin/bash
# Raspberry Pi 3 Installation Script for norns with Pico-LCD-1.14 & I2S Audio

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║              norns Raspberry Pi 3 Installer               ║"
echo "║          Pico-LCD-1.14 + I2S Audio Configuration          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check if running on Raspberry Pi
if ! grep -q "Raspberry Pi" /proc/cpuinfo; then
    echo "❌ This script must be run on a Raspberry Pi"
    exit 1
fi

# Check for Raspberry Pi 3
PI_MODEL=$(grep "Revision" /proc/cpuinfo | awk '{print $3}')
case $PI_MODEL in
    a02082|a22082|a32082)
        echo "✅ Detected: Raspberry Pi 3 Model B"
        ;;
    a020d3)
        echo "✅ Detected: Raspberry Pi 3 Model B+"
        ;;
    *)
        echo "⚠️  Unknown Pi model. Continuing anyway..."
        ;;
esac

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "❌ This script should NOT be run as root"
   echo "   Run as regular user (pi) with sudo when needed"
   exit 1
fi

echo ""
echo "🔧 System Information:"
echo "   OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "   Kernel: $(uname -r)"
echo "   Architecture: $(uname -m)"
echo ""

read -p "Continue with installation? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""
echo "📦 Phase 1: System Update & Dependencies"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Update system
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install dependencies
echo "Installing build dependencies..."
sudo apt install -y \
    git build-essential cmake pkg-config \
    libasound2-dev jackd2 libjack-jackd2-dev \
    alsa-utils device-tree-compiler \
    libgpiod-dev libcairo2-dev libfreetype6-dev \
    libfontconfig1-dev libfftw3-dev libsndfile1-dev \
    liblo-dev libncurses5-dev libreadline-dev \
    libudev-dev libavahi-client-dev \
    libnanomsg-dev libsamplerate0-dev \
    supercollider-server supercollider-common \
    sc3-plugins-server

echo ""
echo "⚙️  Phase 2: Hardware Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Backup config.txt
if [ ! -f /boot/config.txt.backup ]; then
    sudo cp /boot/config.txt /boot/config.txt.backup
    echo "✅ Backed up /boot/config.txt"
fi

# Configure boot settings
echo "Configuring boot settings..."

# Enable SPI
if ! grep -q "dtparam=spi=on" /boot/config.txt; then
    echo "dtparam=spi=on" | sudo tee -a /boot/config.txt
    echo "✅ Enabled SPI interface"
fi

# Enable I2S
if ! grep -q "dtparam=i2s=on" /boot/config.txt; then
    echo "dtparam=i2s=on" | sudo tee -a /boot/config.txt
    echo "✅ Enabled I2S interface"
fi

# Set GPU memory
if ! grep -q "gpu_mem=" /boot/config.txt; then
    echo "gpu_mem=64" | sudo tee -a /boot/config.txt
    echo "✅ Set GPU memory split"
fi

# Performance optimizations for Pi 3
if ! grep -q "arm_freq=" /boot/config.txt; then
    echo "# Performance optimizations" | sudo tee -a /boot/config.txt
    echo "arm_freq=1400" | sudo tee -a /boot/config.txt
    echo "core_freq=500" | sudo tee -a /boot/config.txt  
    echo "sdram_freq=500" | sudo tee -a /boot/config.txt
    echo "over_voltage=6" | sudo tee -a /boot/config.txt
    echo "✅ Added performance optimizations"
fi

# Configure ALSA for I2S
echo "Configuring ALSA..."
sudo tee /etc/asound.conf > /dev/null << 'EOF'
# ALSA configuration for Pi 3 I2S Audio
pcm.picoi2s {
    type hw
    card 0
    device 0
    channels 2
    rate 48000
    format S16_LE
}

ctl.picoi2s {
    type hw
    card 0
}

pcm.!default {
    type plug
    slave.pcm "picoi2s"
}

ctl.!default {
    type hw
    card 0
}
EOF
echo "✅ ALSA configuration updated"

# Configure JACK for Pi 3
echo "Configuring JACK..."
sudo tee /etc/jackdrc > /dev/null << 'EOF'
/usr/bin/jackd -P75 -dalsa -dhw:picoi2s -p256 -n3 -S -r48000
EOF
echo "✅ JACK configuration updated"

echo ""
echo "🏗️  Phase 3: Building norns"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if norns directory exists
if [ ! -d "norns" ]; then
    echo "❌ norns directory not found!"
    echo "   Please run this script from the norns directory"
    echo "   cd ~/norns && ./install-pi3.sh"
    exit 1
fi

# Build matron
echo "Building matron..."
cd matron
if [ -d "build" ]; then
    rm -rf build
fi
./wscript configure
./wscript build
echo "✅ matron built successfully"
cd ..

# Build crone
echo "Building crone..."
cd crone
if [ -d "build" ]; then
    rm -rf build
fi
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
echo "✅ crone built successfully"
cd ../..

echo ""
echo "🎵 Phase 4: Audio Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Install SuperCollider engines
echo "Installing SuperCollider engines..."
cd sc
sudo ./install.sh
cd ..
echo "✅ SuperCollider engines installed"

# Setup user permissions
echo "Setting up user permissions..."
sudo usermod -a -G audio,gpio,spi,i2c $USER
echo "✅ User added to required groups"

# Configure real-time audio
if ! grep -q '@audio.*rtprio' /etc/security/limits.conf; then
    echo '@audio - rtprio 95' | sudo tee -a /etc/security/limits.conf
    echo '@audio - memlock unlimited' | sudo tee -a /etc/security/limits.conf
    echo "✅ Real-time audio limits configured"
fi

echo ""
echo "🔧 Phase 5: System Services"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Copy service files
if [ -f "norns-image/config/norns-jack.service" ]; then
    sudo cp norns-image/config/norns-jack.service /etc/systemd/system/
    echo "✅ Copied norns-jack service"
fi

if [ -f "norns-image/config/norns-crone.service" ]; then
    sudo cp norns-image/config/norns-crone.service /etc/systemd/system/
    echo "✅ Copied norns-crone service"
fi

if [ -f "norns-image/config/norns-matron.service" ]; then
    sudo cp norns-image/config/norns-matron.service /etc/systemd/system/
    echo "✅ Copied norns-matron service"
fi

# Reload systemd
sudo systemctl daemon-reload
echo "✅ Systemd services reloaded"

# Performance tweaks
echo "Applying performance tweaks..."

# CPU governor
echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils > /dev/null

# Disable unnecessary services for audio performance
sudo systemctl disable bluetooth.service
sudo systemctl disable wifi-powersave@wlan0.service 2>/dev/null || true

echo "✅ Performance tweaks applied"

echo ""
echo "🧪 Phase 6: Hardware Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Make test script executable
if [ -f "norns-image/test-pico-hardware.sh" ]; then
    chmod +x norns-image/test-pico-hardware.sh
    echo "Running hardware test..."
    ./norns-image/test-pico-hardware.sh
else
    echo "⚠️  Test script not found, skipping hardware test"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    Installation Complete!                 ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. 🔌 Connect Hardware:"
echo "   • Pico-LCD-1.14 to SPI pins (see README-RASPBERRY-PI-3.md)"
echo "   • I2S Audio Pack to I2S pins"
echo ""
echo "2. 🔄 Reboot System:"
echo "   sudo reboot"
echo ""
echo "3. 🎵 Start Services (after reboot):"
echo "   sudo systemctl start norns-jack"
echo "   sudo systemctl start norns-crone"
echo "   sudo systemctl start norns-matron"
echo ""
echo "4. ✅ Test Installation:"
echo "   ./norns-image/test-pico-hardware.sh"
echo "   aplay /usr/share/sounds/alsa/Front_Left.wav"
echo ""
echo "📖 Documentation:"
echo "   • Full setup guide: README-RASPBERRY-PI-3.md"
echo "   • Hardware info: norns-image/readme-pico-hardware.md"
echo "   • Troubleshooting: See README for common issues"
echo ""
echo "🐛 If you encounter issues:"
echo "   • Check hardware connections"
echo "   • Review system logs: journalctl -u norns-*"
echo "   • Visit: https://llllllll.co/ for community support"
echo ""
echo "⚠️  REBOOT REQUIRED for all changes to take effect!"

exit 0