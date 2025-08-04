# norns with Pico-LCD-1.14 & I2S Audio on Raspberry Pi 3

Complete setup guide for running norns on Raspberry Pi 3 with Pico-LCD-1.14 display and Pimoroni Audio Pack.

## Hardware Requirements

### Main Board
- **Raspberry Pi 3 Model B/B+** (Recommended: B+ for better performance)
- MicroSD card (32GB+ recommended)
- 5V 2.5A power supply

### Display Module
- **Pico-LCD-1.14** (Waveshare 1.14" IPS LCD)
  - Resolution: 240×135 pixels
  - Driver: ST7789
  - Interface: SPI
  - Available from: Waveshare, Amazon, AliExpress

### Audio Module  
- **Pimoroni Audio Pack** (or compatible PCM5100A I2S DAC)
  - DAC: PCM5100A
  - Interface: I2S
  - Output: 3.5mm line out
  - Available from: Pimoroni, Adafruit

### Additional Components
- Breadboard or PCB for connections
- Jumper wires (male-to-female)
- 3.5mm audio cable
- USB keyboard (for initial setup)

## GPIO Pin Connections

### Raspberry Pi 3 GPIO Pinout Reference

```
    3V3  (1) (2)  5V
  GPIO2  (3) (4)  5V
  GPIO3  (5) (6)  GND
  GPIO4  (7) (8)  GPIO14
    GND  (9) (10) GPIO15
 GPIO17 (11) (12) GPIO18
 GPIO27 (13) (14) GND
 GPIO22 (15) (16) GPIO23
    3V3 (17) (18) GPIO24
 GPIO10 (19) (20) GND
  GPIO9 (21) (22) GPIO25
 GPIO11 (23) (24) GPIO8
    GND (25) (26) GPIO7
  GPIO0 (27) (28) GPIO1
  GPIO5 (29) (30) GND
  GPIO6 (31) (32) GPIO12
 GPIO13 (33) (34) GND
 GPIO19 (35) (36) GPIO16
 GPIO26 (37) (38) GPIO20
    GND (39) (40) GPIO21
```

### LCD Connections (Pico-LCD-1.14)

| LCD Pin | Function | Pi 3 GPIO | Pi 3 Pin | Wire Color |
|---------|----------|-----------|----------|------------|
| VCC     | Power    | 3.3V      | Pin 17   | Red        |
| GND     | Ground   | GND       | Pin 25   | Black      |
| DIN     | SPI MOSI | GPIO10    | Pin 19   | Blue       |
| CLK     | SPI SCK  | GPIO11    | Pin 23   | Yellow     |
| CS      | Chip Sel | GPIO8     | Pin 24   | Green      |
| DC      | Data/Cmd | GPIO25    | Pin 22   | Orange     |
| RST     | Reset    | GPIO24    | Pin 18   | Purple     |
| BL      | Backlight| GPIO23    | Pin 16   | White      |

### Audio Connections (I2S)

| Audio Pin | Function | Pi 3 GPIO | Pi 3 Pin | Wire Color |
|-----------|----------|-----------|----------|------------|
| VCC       | Power    | 5V        | Pin 2    | Red        |
| GND       | Ground   | GND       | Pin 6    | Black      |
| DIN       | I2S Data | GPIO21    | Pin 40   | Blue       |
| BCK       | Bit Clock| GPIO18    | Pin 12   | Yellow     |
| LCK       | L/R Clock| GPIO19    | Pin 35   | Green      |

## Software Installation

### 1. Prepare Raspberry Pi OS

**Flash Raspberry Pi OS Lite (64-bit recommended)**

```bash
# Download Raspberry Pi Imager
# Flash "Raspberry Pi OS Lite (64-bit)" to SD card
# Enable SSH in raspi-config before first boot
```

**Initial Setup**
```bash
# Boot Pi and connect via SSH
ssh pi@[PI_IP_ADDRESS]

# Update system
sudo apt update && sudo apt upgrade -y

# Enable SPI and I2S
sudo raspi-config
# -> Interface Options -> SPI -> Enable
# -> Interface Options -> I2C -> Enable  
# -> Advanced Options -> Expand Filesystem
# Reboot when prompted
```

### 2. Clone and Setup norns

```bash
# Install dependencies
sudo apt install -y git build-essential cmake pkg-config \
    libasound2-dev jackd2 libjack-jackd2-dev alsa-utils \
    device-tree-compiler libgpiod-dev libcairo2-dev \
    libfreetype6-dev libfontconfig1-dev

# Clone the modified norns repository
git clone https://github.com/TarasShu/norns.git
cd norns
git checkout pico-lcd-update

# Run the setup script
sudo ./norns-image/setup-pico-norns.sh
```

### 3. Configure Boot Settings

The setup script automatically configures `/boot/config.txt`, but verify these settings:

```bash
# Check /boot/config.txt contains:
sudo nano /boot/config.txt

# Required lines:
dtparam=spi=on
dtparam=i2s=on
gpu_mem=64

# Optional performance settings:
arm_freq=1400
core_freq=500
sdram_freq=500
over_voltage=6
```

### 4. Build norns Components

```bash
cd ~/norns

# Build matron (main engine)
cd matron
./wscript configure
./wscript build
cd ..

# Build crone (audio engine)  
cd crone
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j4
cd ../..

# Install SuperCollider engines
cd sc
sudo ./install.sh
cd ..
```

### 5. Test Hardware

```bash
# Test LCD display
sudo ./norns-image/test-pico-hardware.sh

# Test audio output
aplay /usr/share/sounds/alsa/Front_Left.wav

# Check SPI device
ls -la /dev/spi*

# Check audio devices
aplay -l
```

### 6. Start norns Services

```bash
# Enable and start services
sudo systemctl enable norns-jack norns-crone norns-matron
sudo systemctl start norns-jack
sudo systemctl start norns-crone  
sudo systemctl start norns-matron

# Check service status
sudo systemctl status norns-jack
sudo systemctl status norns-crone
sudo systemctl status norns-matron
```

## Wiring Diagram

```
Raspberry Pi 3                    Pico-LCD-1.14
┌─────────────────┐               ┌───────────────┐
│  3.3V    Pin 17 ├───────────────┤ VCC           │
│  GND     Pin 25 ├───────────────┤ GND           │
│  GPIO10  Pin 19 ├───────────────┤ DIN (MOSI)    │
│  GPIO11  Pin 23 ├───────────────┤ CLK (SCK)     │
│  GPIO8   Pin 24 ├───────────────┤ CS            │
│  GPIO25  Pin 22 ├───────────────┤ DC            │
│  GPIO24  Pin 18 ├───────────────┤ RST           │
│  GPIO23  Pin 16 ├───────────────┤ BL            │
└─────────────────┘               └───────────────┘

Raspberry Pi 3                    Audio Pack (I2S)
┌─────────────────┐               ┌───────────────┐
│  5V      Pin 2  ├───────────────┤ VCC           │
│  GND     Pin 6  ├───────────────┤ GND           │
│  GPIO21  Pin 40 ├───────────────┤ DIN (Data)    │
│  GPIO18  Pin 12 ├───────────────┤ BCK (Clock)   │
│  GPIO19  Pin 35 ├───────────────┤ LCK (L/R)     │
└─────────────────┘               └───────────────┘
```

## Performance Optimization

### CPU Governor
```bash
# Set performance governor
echo 'performance' | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Make permanent
echo 'GOVERNOR="performance"' | sudo tee -a /etc/default/cpufrequtils
```

### Audio Optimization
```bash
# Increase audio buffer size if needed
sudo nano /etc/jackdrc
# Change -p128 to -p256 for higher latency but more stability

# Real-time priorities
sudo usermod -a -G audio pi
echo '@audio - rtprio 95' | sudo tee -a /etc/security/limits.conf
```

### Memory Split
```bash
# Reduce GPU memory if not using HDMI
sudo nano /boot/config.txt
# Set: gpu_mem=16
```

## Troubleshooting

### Display Issues

**Black Screen**
```bash
# Check SPI connection
dmesg | grep spi
ls -la /dev/spi*

# Verify GPIO connections with multimeter
# Check 3.3V power supply
```

**Corrupted Display**
```bash
# Check SPI speed - reduce if needed
sudo nano ~/norns/matron/src/hardware/screen/lcd.c
# Change speed_hz to 40000000 (40MHz)
```

### Audio Issues

**No Audio Output**
```bash
# Check I2S configuration
aplay -l
cat /proc/asound/cards

# Verify JACK is running
ps aux | grep jack

# Check audio connections
alsamixer
```

**Audio Dropouts**
```bash
# Increase buffer size
sudo nano /etc/jackdrc
# Change -p128 to -p256 or -p512

# Check system load
top
# Kill unnecessary processes
```

### Performance Issues

**Slow Response**
```bash
# Check CPU frequency
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq

# Monitor system resources
htop

# Disable unnecessary services
sudo systemctl disable bluetooth
sudo systemctl disable wifi-powersave@wlan0
```

**Memory Issues**
```bash
# Check memory usage
free -h

# Reduce GPU memory
sudo nano /boot/config.txt
# Set: gpu_mem=16

# Add swap if needed
sudo dphys-swapfile setup
```

## Advanced Configuration

### Custom Display Resolution
```c
// Edit matron/src/hardware/screen/lcd.h
#define LCD_WIDTH 240
#define LCD_HEIGHT 135

// Rebuild matron after changes
cd ~/norns/matron
./wscript clean
./wscript configure
./wscript build
```

### Audio Sample Rate
```bash
# Change sample rate in JACK config
sudo nano /etc/jackdrc
# Change -r48000 to desired rate (44100, 48000, 96000)

# Restart audio services
sudo systemctl restart norns-jack
sudo systemctl restart norns-crone
```

### GPIO Remapping
If you need different GPIO pins, edit:
```c
// matron/src/hardware/screen/lcd.h
#define LCD_DC_GPIO_LINE 25    // Change as needed
#define LCD_RESET_GPIO_LINE 24 // Change as needed
// etc.
```

## Support & Resources

- **norns Community**: https://llllllll.co/
- **Original norns**: https://github.com/monome/norns
- **This Fork**: https://github.com/TarasShu/norns/tree/pico-lcd-update
- **Hardware Docs**: See `norns-image/readme-pico-hardware.md`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on Pi 3 hardware
5. Submit a pull request

---

**Note**: This setup has been tested on Raspberry Pi 3 Model B+. Performance may vary on older models.