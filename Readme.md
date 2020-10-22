# ASUS X442UR/R Hackintosh
This is EFI Patch based on OpenCore bootloader that I've made. It's just for series X442UR, X442URR, A442UR, or A442URR, if you're facing a problem using this EFI, you can open issue in this repo or contact me on [Telegram](https://t.me/hamcuks)

![About This Mac](https://github.com/hamcuks/hackintosh-x442urr/blob/master/Screnshots/ss-about.png?raw=true)
![Opencore Bootloader](https://github.com/hamcuks/hackintosh-x442urr/blob/master/Screnshots/ss-bl.png?raw=true)
![Intel UHD 620 Graphics](https://github.com/hamcuks/hackintosh-x442urr/blob/master/Screnshots/ss-gpu.png?raw=true)
![Credit patch](https://github.com/hamcuks/hackintosh-x442urr/blob/master/Screnshots/ss-pci.png?raw=true)
![Peripheral](https://github.com/hamcuks/hackintosh-x442urr/blob/master/Screnshots/ss-peripheral.png?raw=true)
![SATA](https://github.com/hamcuks/hackintosh-x442urr/blob/master/Screnshots/ss-sata.png?raw=true)
![WiFi Intel 6 AX200](https://github.com/hamcuks/hackintosh-x442urr/blob/master/Screnshots/ss-wifi.png?raw=true)


## Technical Specs

Specifications | Detail
------------| ----------
Computer Model | ASUS X442URR
Processor   | Intel Core i5-8250U
iGPU        | Intel UHD 620 Graphics
dGPU        | Nvidia 930MX
Storage     | ADATA 120GB SSD SATAIII
RAM         | 2 x 4GB
WLAN        | Intel Wi-Fi 6 AX200
Ethernet    | RTL8111/8168H
Trackpad    | Elan 1200 I2C
Audio | Realtek ALC256 Audio Codec
Bios Version | X442URR.308
 
## Bootloader
Bootloader        | Verson
------------| ----------
OpenCore | 0.6.2
Clover | Ongoing

## BIOS Configuration
Please disable this configurations in BIOS. You can enable again after installation
- Vt-D
- Vt-X
- CSM 
- Secure Boot
- set DVMT-Prealloc to 64MB

## Supported macOS
- Big Sur 11.0 Beta 10 => Tested, OC 0.6.2
- Catalina => Not tested yet, ongoing
- Mojave => Not tested yet, ongoing

## Whats working?
- QE/CI Intel UHD Graphis 620
- Power Management
- Shutdown, Restart, Sleep (ongoing test), Wake
- Audio speaker, Int mic., Headphone
- Wi-Fi with AirportItlwm.kext and Blueetooth
- Trackpad Full Gesture, running on Interrup mode
- Camera
- etc

## Not working and not tested
- Ethernet, detected on DPCIManager but not tested yet
- VGA, not tested yet
- Nvidia 930MX (disabled)
- Card reader
- iMessage, facetime. Not really important right now
- etc

## Known Issues
- When in sleep, sometimes wake up itself. Wake reason: RTC (Alarm)
- No internet connection after wake from sleep. This is issue when using Airportitlwm.kext, you can go to syspref > network > turn off and turn on again, then reconnect your Wi-Fi or you can reboot your machine. Or you can using itlwm.kext + heliport.app instead of AiportItlwm.kext

## Config.plist Configuration
1. This EFI not include with SMBIOS, so you have set it to MacbookPro14,1 SMBIOS
2. Download as Zip or you can clone this repo using git
3. Download genSMBIOS [here](https://github.com/corpnewt/GenSMBIOS)
4. Double click `GenSMBIOS.command` that in GenSMBIOS folder
5. Enter 2 to select config.plist, then drag and drop the config.plist that in EFI Folder and then press enter key
6. Enter 3 to generate SMBIOS, type MacbookPro14,1 and then press enter key
7. Done

## Credits
- [H4CK1NTOSH L0V3R](https://t.me/HackintoshLover) Group
- [Dortania](https://dortania.github.io) as their pretty nice guide
- [Zenbook Hackintosh by Hieplpvip](https://github.com/hieplpvip/Asus-Zenbook-Hackintosh)

## Terima Kasih, Matur Nuwun, Kamboto Terimakasih, Hatur Nuhun
