# norns Pico hardware configuration

This document describes the hardware configuration for running norns with Pico-LCD-1.14 display and Pico I2S audio (Pimoroni Audio Pack).

## SoC

Raspberry Pi Pico (RP2040)

Dual core ARM Cortex-M0+ at 133MHz, 264KB RAM, 2MB Flash

## Display

### Pico-LCD-1.14

1.14 inch IPS LCD display with 240×135 resolution and 65K colors.

- **Driver**: ST7789
- **Interface**: SPI
- **Resolution**: 240×135 pixels
- **Colors**: 65K RGB (16-bit color depth)

#### Pinout

The display is connected via SPI interface with the following GPIO pins:

- **PIN: SPI MOSI (SDA)** = GPIO19 
- **PIN: SPI SCK (SCL)** = GPIO18
- **PIN: SPI CS (CSX)** = GPIO17
- **PIN: DC (D/CX)** = GPIO15
- **PIN: RESET (RESX)** = GPIO14  
- **PIN: BACKLIGHT** = GPIO13

#### Configuration

The display uses SPI0 with the following settings:
- **SPI Mode**: Mode 0 (CPOL=0, CPHA=0)
- **Speed**: 80MHz
- **Bit Order**: MSB first
- **Data Width**: 8 bits

## Audio

### Pico I2S Audio (Pimoroni Audio Pack)

High quality stereo DAC using PCM5100A for audio output.

- **DAC**: PCM5100A  
- **Interface**: I2S
- **Sample Rate**: Up to 384KHz
- **Bit Depth**: Up to 32-bit
- **Output**: 3.5mm line out

#### Pinout

The I2S audio interface uses the following GPIO pins:

- **PIN: I2S_DATA (DOUT)** = GPIO9
- **PIN: I2S_BCLK (BCK)** = GPIO10
- **PIN: I2S_LRCK (LCK)** = GPIO11

#### Configuration

I2S audio is configured as follows:
- **Sample Rate**: 48KHz (default)
- **Format**: I2S
- **Channels**: 2 (stereo)
- **Bit Depth**: 16-bit (S16_LE)

#### ALSA Setup

ALSA is configured to use the I2S interface with device name `picoi2s`.

Configuration file: `/etc/asound.conf`

```
pcm.picoi2s {
    type hw
    card 0
    device 0
    channels 2
    rate 48000
    format S16_LE
}
```

#### JACK Setup

JACK is configured to use the ALSA I2S device:

```
/usr/bin/jackd -R -P 95 -d alsa -d hw:picoi2s -r 48000 -n 3 -p 128 -S -s
```

## Controls

The original norns controls (keys and encoders) can be connected to available GPIO pins or external controllers can be used via USB.

## Setup Instructions

1. **Enable I2S**: Add `dtparam=i2s=on` to `/boot/config.txt`
2. **Load overlay**: Add `dtoverlay=pico-i2s,i2s_pins=9` to `/boot/config.txt`
3. **Copy ALSA config**: Copy `pico-i2s-audio.conf` to `/etc/asound.conf`
4. **Reboot**: Restart the system for changes to take effect

## GPIO Pin Summary

| Function | GPIO Pin | Description |
|----------|----------|-------------|
| LCD_MOSI | 19 | SPI data to display |
| LCD_SCK  | 18 | SPI clock to display |
| LCD_CS   | 17 | SPI chip select for display |
| LCD_DC   | 15 | Data/Command control for display |
| LCD_RST  | 14 | Reset pin for display |
| LCD_BL   | 13 | Backlight control for display |
| I2S_LRCK | 11 | I2S left/right clock |
| I2S_BCLK | 10 | I2S bit clock |
| I2S_DATA | 9  | I2S data output |

## Power

Power is provided via USB-C connector on the Pico board. The Pico-LCD-1.14 and audio hardware are powered directly from the Pico's 3.3V supply.

## Notes

- The ST7789 display driver supports higher refresh rates than the original SSD1322 OLED
- I2S audio provides better quality than the original CS4720 codec setup
- GPIO pins not used for display/audio are available for other functions
- The RP2040's PIO (Programmable I/O) is used to implement the I2S interface