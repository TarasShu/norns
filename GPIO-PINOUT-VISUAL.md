# Raspberry Pi 3 GPIO Visual Pinout for norns Pico Setup

## Complete GPIO Pinout Diagram

```
                    Raspberry Pi 3 GPIO Header
                           (40 pins)
    
    3.3V PWR ●─────●●─────● 5V PWR
             1     2
    GPIO 2   ●─────●●─────● 5V PWR  
             3     4
    GPIO 3   ●─────●●─────● GND
             5     6        ↑
    GPIO 4   ●─────●●─────● GPIO 14   Audio GND
             7     8
      GND    ●─────●●─────● GPIO 15
             9     10
    GPIO 17  ●─────●●─────● GPIO 18  ← I2S BCK (Audio)
             11    12       ↑
    GPIO 27  ●─────●●─────● GND
             13    14
    GPIO 22  ●─────●●─────● GPIO 23  ← LCD BL (Backlight)
             15    16       ↑
    3.3V PWR ●─────●●─────● GPIO 24  ← LCD RST (Reset)
             17    18       ↑
    GPIO 10  ●─────●●─────● GND
             19    20       ↑
             ↑              LCD GND
         LCD DIN
         (SPI MOSI)
    
    GPIO 9   ●─────●●─────● GPIO 25  ← LCD DC (Data/Command)
             21    22       ↑
    GPIO 11  ●─────●●─────● GPIO 8   ← LCD CS (Chip Select)
             23    24       ↑
             ↑
         LCD CLK
         (SPI SCK)
    
      GND    ●─────●●─────● GPIO 7
             25    26
    GPIO 0   ●─────●●─────● GPIO 1
             27    28
    GPIO 5   ●─────●●─────● GND
             29    30
    GPIO 6   ●─────●●─────● GPIO 12
             31    32
    GPIO 13  ●─────●●─────● GND
             33    34
    GPIO 19  ●─────●●─────● GPIO 16
             35    36
             ↑
         I2S LCK
         (L/R Clock)
    
    GPIO 26  ●─────●●─────● GPIO 20
             37    38
      GND    ●─────●●─────● GPIO 21  ← I2S DIN (Audio Data)
             39    40       ↑
```

## Connection Summary with Colors

### 🔴 Power Connections
```
3.3V (Pin 17) ──────────────● LCD VCC (Red wire)
5V   (Pin 2)  ──────────────● Audio VCC (Red wire)
GND  (Pin 6)  ──────────────● Audio GND (Black wire)
GND  (Pin 20) ──────────────● LCD GND (Black wire)
```

### 📺 LCD Display Connections (Pico-LCD-1.14)
```
GPIO 10 (Pin 19) ──────────● LCD DIN  (Blue wire)
GPIO 11 (Pin 23) ──────────● LCD CLK  (Yellow wire)
GPIO 8  (Pin 24) ──────────● LCD CS   (Green wire)
GPIO 25 (Pin 22) ──────────● LCD DC   (Orange wire)
GPIO 24 (Pin 18) ──────────● LCD RST  (Purple wire)
GPIO 23 (Pin 16) ──────────● LCD BL   (White wire)
```

### 🎵 I2S Audio Connections (Pimoroni Audio Pack)
```
GPIO 21 (Pin 40) ──────────● Audio DIN (Blue wire)
GPIO 18 (Pin 12) ──────────● Audio BCK (Yellow wire)
GPIO 19 (Pin 35) ──────────● Audio LCK (Green wire)
```

## Physical Layout View (Looking Down at Pi)

```
    ┌─────────────────────────────────────────────┐
    │                                             │
    │  ●○●○●○●○●○●○●○●○●○●○●○●○●○●○●○●○●○●○●○●○  │
    │  ●○●○●○●○●○●○●○●○●○●○●○●○●○●○●○●○●○●○●○●○  │
    │   1 3 5 7 9  ...               ...  37 39  │
    │   2 4 6 8 10 ...               ...  38 40  │
    │                                             │
    │              Raspberry Pi 3                 │
    │                                             │
    └─────────────────────────────────────────────┘
                           ↑
                    GPIO Header
    
    Pin 1 (3.3V) is closest to SD card slot
    Pin 2 (5V) is closest to USB ports
```

## Side-by-Side Connection Diagram

```
    Raspberry Pi 3                    Pico-LCD-1.14
    ┌─────────────┐                   ┌─────────────┐
    │             │ Red    ──────────►│ VCC         │
    │ 3.3V Pin 17 │                   │             │
    │             │ Black  ──────────►│ GND         │
    │ GND  Pin 20 │                   │             │
    │             │ Blue   ──────────►│ DIN (MOSI)  │
    │ GPIO10 P19  │                   │             │
    │             │ Yellow ──────────►│ CLK (SCK)   │
    │ GPIO11 P23  │                   │             │
    │             │ Green  ──────────►│ CS          │
    │ GPIO8  P24  │                   │             │
    │             │ Orange ──────────►│ DC          │
    │ GPIO25 P22  │                   │             │
    │             │ Purple ──────────►│ RST         │
    │ GPIO24 P18  │                   │             │
    │             │ White  ──────────►│ BL          │
    │ GPIO23 P16  │                   │             │
    └─────────────┘                   └─────────────┘

    Raspberry Pi 3                    Audio Pack (I2S)
    ┌─────────────┐                   ┌─────────────┐
    │             │ Red    ──────────►│ VCC         │
    │ 5V   Pin 2  │                   │             │
    │             │ Black  ──────────►│ GND         │
    │ GND  Pin 6  │                   │             │
    │             │ Blue   ──────────►│ DIN (Data)  │
    │ GPIO21 P40  │                   │             │
    │             │ Yellow ──────────►│ BCK (Clock) │
    │ GPIO18 P12  │                   │             │
    │             │ Green  ──────────►│ LCK (L/R)   │
    │ GPIO19 P35  │                   │             │
    └─────────────┘                   └─────────────┘
```

## Breadboard Layout Example

```
    LCD Module                     Raspberry Pi 3
    ┌─────────┐                    ┌─────────────┐
    │ Pico-   │                    │ Pin Layout  │
    │ LCD-1.14│                    │             │
    │         │                    │ 1  2  ← 5V  │
    │ VCC ●───┼────────────────────┼─● 17 ← 3.3V │
    │ GND ●───┼────────────────────┼─● 20 ← GND  │
    │ DIN ●───┼────────────────────┼─● 19 ← GP10 │
    │ CLK ●───┼────────────────────┼─● 23 ← GP11 │
    │ CS  ●───┼────────────────────┼─● 24 ← GP8  │
    │ DC  ●───┼────────────────────┼─● 22 ← GP25 │
    │ RST ●───┼────────────────────┼─● 18 ← GP24 │
    │ BL  ●───┼────────────────────┼─● 16 ← GP23 │
    └─────────┘                    │             │
                                   │             │
    Audio Pack                     │             │
    ┌─────────┐                    │             │
    │ Pimoroni│                    │             │
    │ I2S DAC │                    │             │
    │         │                    │             │
    │ VCC ●───┼────────────────────┼─●  2 ← 5V   │
    │ GND ●───┼────────────────────┼─●  6 ← GND  │
    │ DIN ●───┼────────────────────┼─● 40 ← GP21 │
    │ BCK ●───┼────────────────────┼─● 12 ← GP18 │
    │ LCK ●───┼────────────────────┼─● 35 ← GP19 │
    └─────────┘                    └─────────────┘
```

## Quick Reference Card

```
╔══════════════════════════════════════════════════════════╗
║                  norns Pico GPIO Guide                  ║
╠══════════════════════════════════════════════════════════╣
║ LCD Display (Pico-LCD-1.14)                             ║
║ ─────────────────────────────────────────────────────── ║
║ Power:  3.3V(17) + GND(20)                              ║
║ SPI:    MOSI(19) + SCK(23) + CS(24)                     ║
║ Control: DC(22) + RST(18) + BL(16)                      ║
║                                                          ║
║ I2S Audio (Pimoroni Audio Pack)                         ║
║ ─────────────────────────────────────────────────────── ║
║ Power:  5V(2) + GND(6)                                  ║
║ I2S:    DATA(40) + BCK(12) + LCK(35)                    ║
║                                                          ║
║ Pin Numbers: (Physical pin on 40-pin header)            ║
╚══════════════════════════════════════════════════════════╝
```

## Testing Connections

Use this checklist to verify your wiring:

```
LCD Connections Test:
□ Red wire:    3.3V (Pin 17) → LCD VCC
□ Black wire:  GND (Pin 20)  → LCD GND  
□ Blue wire:   GPIO10 (19)   → LCD DIN
□ Yellow wire: GPIO11 (23)   → LCD CLK
□ Green wire:  GPIO8 (24)    → LCD CS
□ Orange wire: GPIO25 (22)   → LCD DC
□ Purple wire: GPIO24 (18)   → LCD RST
□ White wire:  GPIO23 (16)   → LCD BL

Audio Connections Test:
□ Red wire:    5V (Pin 2)    → Audio VCC
□ Black wire:  GND (Pin 6)   → Audio GND
□ Blue wire:   GPIO21 (40)   → Audio DIN
□ Yellow wire: GPIO18 (12)   → Audio BCK
□ Green wire:  GPIO19 (35)   → Audio LCK
```

**🔧 Use a multimeter to verify connections before powering on!**