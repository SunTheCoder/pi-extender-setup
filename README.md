# Raspberry Pi Zero 2W Network Extender

This project configures a Raspberry Pi Zero 2W as a wireless network extender for an existing WiFi network.

## Features
- Extends the range of an existing WiFi network
- Uses the same SSID and password as the main network
- Automatic device switching between main router and extender
- Easy setup with a single script
- Offline installation support

## Requirements
- Raspberry Pi Zero 2W
- Raspberry Pi OS (latest version)
- Stable power supply

## Network Details
- Network Name (SSID): OffGridNet
- Password: Datathug2024!

## Setup Instructions

### Preparing the Packages (On a computer with internet access)

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/pi-extender-setup.git
   cd pi-extender-setup
   ```

2. Download the required packages:
   ```bash
   chmod +x download_packages.sh
   ./download_packages.sh
   ```

3. Commit the packages to the repository:
   ```bash
   git add packages/
   git commit -m "Add offline installation packages"
   git push
   ```

### Installing on the Raspberry Pi

1. Clone this repository (or copy the files if you don't have Git):
   ```bash
   git clone https://github.com/yourusername/pi-extender-setup.git
   cd pi-extender-setup
   ```

2. Make the setup script executable:
   ```bash
   chmod +x setup.sh
   ```

3. Run the setup script:
   ```bash
   sudo ./setup.sh
   ```

4. The Pi will reboot after configuration. After reboot, it will:
   - Connect to the existing network
   - Extend the network range
   - Use the same SSID and password

## Configuration Files
- `setup.sh`: Main setup script
- `download_packages.sh`: Script to download required packages
- Configuration files are generated during setup:
  - `/etc/hostapd/hostapd.conf`
  - `/etc/wpa_supplicant/wpa_supplicant.conf`
  - `/etc/dnsmasq.conf`

## Troubleshooting
If you encounter issues:
1. Check the system logs:
   ```bash
   sudo journalctl -u hostapd
   sudo journalctl -u dnsmasq
   ```
2. Verify network connectivity:
   ```bash
   ifconfig
   iwconfig
   ``` 