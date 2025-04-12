#!/bin/bash

# Check if running as root
if [[ $EUID -gt 0 ]]; then
    echo "Please run as root/sudo"
    exit 1
fi

echo "Uninstalling WiFi extender..."

# Stop and disable services
echo "Stopping services..."
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq
sudo systemctl disable hostapd
sudo systemctl disable dnsmasq

# Restore original networking
echo "Restoring original networking..."
sudo systemctl unmask networking.service dhcpcd.service
sudo mv /etc/network/{interfaces~,interfaces} 2>/dev/null || true
sudo systemctl disable systemd-networkd.service systemd-resolved.service

# Remove configuration files
echo "Removing configuration files..."
sudo rm -f /etc/hostapd/hostapd.conf
sudo rm -f /etc/dnsmasq.conf
sudo rm -f /etc/systemd/network/08-wlan0.network
sudo rm -f /etc/wpa_supplicant/wpa_supplicant.conf

# Restore resolv.conf
echo "Restoring resolv.conf..."
sudo rm -f /etc/resolv.conf
sudo cp /etc/{resolv.conf~,resolv.conf} 2>/dev/null || true

# Remove iptables rules
echo "Removing iptables rules..."
sudo rm -f /etc/iptables.ipv4.nat
sudo sed -i '/iptables-restore/d' /etc/rc.local

echo "Uninstall complete! Rebooting..."
sleep 2
sudo reboot 