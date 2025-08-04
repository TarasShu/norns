#!/bin/bash
# Complete setup script for norns with Pico-LCD-1.14 and Pico I2S Audio

set -e

echo "=== norns Pico Hardware Setup ==="
echo "Setting up Pico-LCD-1.14 display and Pico I2S audio..."

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 
   exit 1
fi

# Backup original config
if [ ! -f /boot/config.txt.backup ]; then
    cp /boot/config.txt /boot/config.txt.backup
    echo "Backed up original /boot/config.txt"
fi

# Configure boot settings
echo "Configuring boot settings..."

# Enable SPI for LCD
if ! grep -q "dtparam=spi=on" /boot/config.txt; then
    echo "dtparam=spi=on" >> /boot/config.txt
    echo "Enabled SPI interface"
fi

# Enable I2S for audio
if ! grep -q "dtparam=i2s=on" /boot/config.txt; then
    echo "dtparam=i2s=on" >> /boot/config.txt
    echo "Enabled I2S interface"
fi

# Set GPU memory split (needed for display)
if ! grep -q "gpu_mem=" /boot/config.txt; then
    echo "gpu_mem=64" >> /boot/config.txt
    echo "Set GPU memory split"
fi

# Configure ALSA for I2S audio
echo "Configuring ALSA for I2S audio..."
cat > /etc/asound.conf << 'EOF'
# ALSA configuration for Pico I2S Audio
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

# Set as default
pcm.!default {
    type plug
    slave.pcm "picoi2s"
}

ctl.!default {
    type hw
    card 0
}
EOF

echo "ALSA configuration updated"

# Update norns services for new hardware
echo "Updating norns services..."

# Update JACK configuration
if [ -f /home/we/norns/norns-image/config/jackdrc ]; then
    cp /home/we/norns/norns-image/config/jackdrc /etc/jackdrc
    echo "Updated JACK configuration"
fi

# Update systemd service
if [ -f /home/we/norns/norns-image/config/norns-jack.service ]; then
    cp /home/we/norns/norns-image/config/norns-jack.service /etc/systemd/system/
    systemctl daemon-reload
    echo "Updated norns-jack service"
fi

# Set permissions
echo "Setting permissions..."
usermod -a -G audio we
usermod -a -G gpio we

# Install/update required packages
echo "Installing required packages..."
apt-get update
apt-get install -y \
    libasound2-dev \
    jackd2 \
    libjack-jackd2-dev \
    alsa-utils \
    device-tree-compiler

# Enable SPI and I2S kernel modules
echo "Configuring kernel modules..."
if ! grep -q "snd-bcm2835" /etc/modules; then
    echo "snd-bcm2835" >> /etc/modules
fi

if ! grep -q "i2c-dev" /etc/modules; then
    echo "i2c-dev" >> /etc/modules
fi

# Set up udev rules for GPIO access
cat > /etc/udev/rules.d/99-gpio.rules << 'EOF'
# GPIO access for norns
SUBSYSTEM=="gpio", GROUP="gpio", MODE="0664"
SUBSYSTEM=="spidev", GROUP="spi", MODE="0664"
EOF

# Reload udev rules
udevadm control --reload-rules

echo "=== Setup Complete ==="
echo ""
echo "Hardware configuration:"
echo "  - Display: Pico-LCD-1.14 (ST7789, 240x135, SPI)"
echo "  - Audio: Pico I2S (PCM5100A DAC, 48KHz)"
echo ""  
echo "GPIO Pin Assignments:"
echo "  LCD: MOSI=19, SCK=18, CS=17, DC=15, RST=14, BL=13"
echo "  I2S: DATA=9, BCLK=10, LRCK=11"
echo ""
echo "Next steps:"
echo "  1. Connect Pico-LCD-1.14 to SPI pins"
echo "  2. Connect Pimoroni Audio Pack to I2S pins"  
echo "  3. Reboot system: sudo reboot"
echo "  4. Test audio: aplay /usr/share/sounds/alsa/Front_Left.wav"
echo ""
echo "REBOOT REQUIRED for changes to take effect!"

exit 0