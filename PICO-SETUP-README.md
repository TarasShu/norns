# norns Pico-LCD-1.14 & I2S Audio Setup

This repository contains the modified norns codebase to work with:
- **Pico-LCD-1.14** display (ST7789 driver, 240×135 resolution)  
- **Pico I2S Audio** (Pimoroni Audio Pack with PCM5100A DAC)

## Changes Made

### 1. LCD Driver Updates (`matron/src/hardware/screen/`)

- **`lcd.h`**: Updated GPIO pin definitions for Pico-LCD-1.14
- **`lcd.c`**: Implemented ST7789 initialization sequence and SPI configuration

Key changes:
- GPIO pins: DC=15, RST=14, BL=13, CS=17, MOSI=19, SCK=18
- SPI speed: 80MHz for ST7789
- Display resolution: 240×135 pixels
- Color format: RGB565 (16-bit)

### 2. Audio Configuration Updates

- **`norns-image/config/jackdrc`**: Updated JACK to use `hw:picoi2s` device
- **`norns-image/config/norns-jack.service`**: Updated systemd service for I2S audio
- **`norns-image/config/pico-i2s-audio.conf`**: ALSA configuration for I2S audio
- **`norns-image/config/pico-i2s-overlay.dts`**: Device tree overlay for I2S pins

### 3. Setup Scripts

- **`setup-pico-norns.sh`**: Complete automated setup script
- **`test-pico-hardware.sh`**: Hardware verification script  
- **`setup-pico-i2s.sh`**: I2S audio specific setup

### 4. Documentation

- **`readme-pico-hardware.md`**: Complete hardware documentation
- **`PICO-SETUP-README.md`**: This setup guide

## Hardware Requirements

### Display: Pico-LCD-1.14
- 1.14" IPS LCD, 240×135 resolution
- ST7789 driver chip
- SPI interface
- Available from Waveshare

### Audio: Pimoroni Audio Pack  
- PCM5100A DAC
- I2S interface
- 3.5mm line output
- Up to 32-bit/384KHz support

## GPIO Pin Assignments

| Function | GPIO | Description |
|----------|------|-------------|
| LCD_MOSI | 19   | SPI data to display |
| LCD_SCK  | 18   | SPI clock |  
| LCD_CS   | 17   | Chip select |
| LCD_DC   | 15   | Data/Command |
| LCD_RST  | 14   | Reset |
| LCD_BL   | 13   | Backlight |
| I2S_LRCK | 11   | Left/Right clock |
| I2S_BCLK | 10   | Bit clock |
| I2S_DATA | 9    | Audio data |

## Installation

1. **Clone this repository**:
   ```bash
   git clone [your-repo-url]
   cd norns-pico
   ```

2. **Run setup script**:
   ```bash
   sudo ./norns-image/setup-pico-norns.sh
   ```

3. **Connect hardware** according to pin assignments above

4. **Reboot system**:
   ```bash
   sudo reboot
   ```

5. **Test installation**:
   ```bash
   ./norns-image/test-pico-hardware.sh
   ```

## Building norns

Follow standard norns build instructions:

```bash
# Install dependencies
sudo apt install build-essential cmake pkg-config

# Build matron
cd matron  
./wscript configure
./wscript build

# Build crone
cd ../crone
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make
```

## Troubleshooting

### Display Issues
- Check SPI connections and GPIO pin assignments
- Verify `/dev/spidev0.0` exists
- Check boot config has `dtparam=spi=on`

### Audio Issues  
- Verify I2S connections (GPIO 9, 10, 11)
- Check ALSA configuration: `aplay -l`
- Test audio: `aplay /usr/share/sounds/alsa/Front_Left.wav`
- Ensure `dtparam=i2s=on` in `/boot/config.txt`

### Build Issues
- Install all development dependencies
- Check for missing libraries: `pkg-config --list-all | grep jack`

## Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test thoroughly  
5. Submit pull request

## License

Same as original norns project.

## Credits

- Original norns by Monome
- Pico-LCD-1.14 by Waveshare
- Pimoroni Audio Pack by Pimoroni
- Adapted for Pico hardware by [Your Name]