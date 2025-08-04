#!/bin/bash
# Setup script for Pico I2S Audio configuration

# Configure GPIO pins for I2S audio (Pimoroni Audio Pack pinout)
# GPIO9  - I2S_DATA (DOUT)
# GPIO10 - I2S_BCLK (BCK)  
# GPIO11 - I2S_LRCK (LCK)

# Enable I2S interface
echo "Configuring I2S pins for Pico Audio Pack..."

# Set GPIO pin functions for I2S
# This would typically be done via device tree overlay
# but can also be set via GPIO configuration

# GPIO 9 = I2S_DATA
echo 9 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio9/direction

# GPIO 10 = I2S_BCLK  
echo 10 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio10/direction

# GPIO 11 = I2S_LRCK
echo 11 > /sys/class/gpio/export  
echo out > /sys/class/gpio/gpio11/direction

# Load ALSA configuration
cp /home/we/norns/norns-image/config/pico-i2s-audio.conf /etc/asound.conf

# Compile and load device tree overlay
dtc -@ -I dts -O dtb -o /boot/overlays/pico-i2s.dtbo /home/we/norns/norns-image/config/pico-i2s-overlay.dts

# Add overlay to config.txt if not already present
if ! grep -q "dtoverlay=pico-i2s" /boot/config.txt; then
    echo "dtoverlay=pico-i2s,i2s_pins=9" >> /boot/config.txt
fi

# Enable I2S in config.txt if not already present
if ! grep -q "dtparam=i2s=on" /boot/config.txt; then
    echo "dtparam=i2s=on" >> /boot/config.txt
fi

echo "I2S configuration complete. Reboot required to take effect."