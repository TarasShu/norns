#!/bin/bash
# Test script for Pico-LCD-1.14 and Pico I2S Audio setup

echo "=== norns Pico Hardware Test ==="

# Test LCD/Display
echo "Testing LCD display..."
if [ -f /dev/fb0 ]; then
    echo "✓ Framebuffer device found"
else
    echo "✗ Framebuffer device not found"
fi

# Test SPI device
echo "Testing SPI interface..."
if [ -c /dev/spidev0.0 ]; then
    echo "✓ SPI device found"
else
    echo "✗ SPI device not found"
fi

# Test I2S/Audio
echo "Testing audio interface..."
if aplay -l | grep -q "picoi2s\|card 0"; then
    echo "✓ Audio device found"
else
    echo "✗ Audio device not found"
fi

# Test JACK
echo "Testing JACK audio..."
if command -v jackd >/dev/null 2>&1; then
    echo "✓ JACK installed"
    if pgrep -x "jackd" > /dev/null; then
        echo "✓ JACK is running"
    else
        echo "! JACK is not running (this is normal if not started yet)"
    fi
else
    echo "✗ JACK not installed"
fi

# Test GPIO access
echo "Testing GPIO access..."
if [ -d /sys/class/gpio ]; then
    echo "✓ GPIO interface available"
else
    echo "✗ GPIO interface not available"
fi

# Check kernel modules
echo "Checking kernel modules..."
if lsmod | grep -q "spi_bcm2835"; then
    echo "✓ SPI module loaded"
else
    echo "! SPI module not loaded"
fi

if lsmod | grep -q "snd_soc"; then
    echo "✓ Sound SoC module loaded"
else
    echo "! Sound SoC module not loaded"
fi

# Check config files
echo "Checking configuration files..."
if [ -f /etc/asound.conf ]; then
    echo "✓ ALSA configuration found"
else
    echo "✗ ALSA configuration missing"
fi

if [ -f /boot/config.txt ]; then
    if grep -q "dtparam=spi=on" /boot/config.txt; then
        echo "✓ SPI enabled in boot config"
    else
        echo "✗ SPI not enabled in boot config"
    fi
    
    if grep -q "dtparam=i2s=on" /boot/config.txt; then
        echo "✓ I2S enabled in boot config"
    else
        echo "✗ I2S not enabled in boot config"
    fi
fi

echo ""
echo "=== Test Complete ==="
echo "If any tests failed, run the setup script again or check hardware connections."