#!/bin/bash

# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install required packages
sudo apt-get install -y hostapd dnsmasq

# Stop services
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq

# Create wpa_supplicant configuration
sudo cat > /etc/wpa_supplicant/wpa_supplicant.conf << EOL
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="OffGridNet"
    psk="Datathug2024!"
    key_mgmt=WPA-PSK
}
EOL

# Configure hostapd
sudo cat > /etc/hostapd/hostapd.conf << EOL
interface=wlan0
driver=nl80211
ssid=OffGridNet
hw_mode=g
channel=6
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=Datathug2024!
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOL

# Configure hostapd to use our config
sudo sed -i 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/' /etc/default/hostapd

# Configure dnsmasq
sudo cat > /etc/dnsmasq.conf << EOL
interface=wlan0
dhcp-range=192.168.1.50,192.168.1.150,12h
EOL

# Enable IP forwarding
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo sysctl -p

# Configure NAT
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
sudo iptables -A FORWARD -i wlan0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o wlan0 -j ACCEPT
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

# Add iptables restore on boot
sudo sed -i '/exit 0/i iptables-restore < /etc/iptables.ipv4.nat' /etc/rc.local

# Start services
sudo systemctl start hostapd
sudo systemctl start dnsmasq
sudo systemctl enable hostapd
sudo systemctl enable dnsmasq

# Reboot to apply changes
sudo reboot 