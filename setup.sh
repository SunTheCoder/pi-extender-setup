#!/bin/bash

# Check if running as root
if [[ $EUID -gt 0 ]]; then
    echo "Please run as root/sudo"
    exit 1
fi

# Network details
SSID="OffGridNet"
PASSWORD="Datathug2024!"

# Check for wireless interfaces
echo "Checking wireless interfaces..."
if ! iw dev | grep -q "wlan0"; then
    echo "Error: wlan0 interface not found"
    exit 1
fi

# Install required packages from local directory
echo "Installing packages..."
sudo dpkg -i packages/*.deb

# Stop and disable services
echo "Configuring services..."
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq
sudo systemctl stop wpa_supplicant

# Setup systemd-networkd
echo "Setting up systemd-networkd..."
sudo systemctl mask networking.service dhcpcd.service
sudo mv /etc/network/{interfaces,interfaces~} 2>/dev/null || true
sudo cp /etc/{resolv.conf,resolv.conf~}
sudo sed -i '1i resolvconf=NO' /etc/resolvconf.conf
sudo systemctl enable systemd-networkd.service systemd-resolved.service
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

# Create wpa_supplicant configuration
echo "Creating wpa_supplicant configuration..."
sudo cat > /etc/wpa_supplicant/wpa_supplicant.conf << EOL
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="$SSID"
    psk="$PASSWORD"
    key_mgmt=WPA-PSK
}
EOL

# Configure hostapd
echo "Configuring hostapd..."
sudo cat > /etc/hostapd/hostapd.conf << EOL
interface=wlan0
driver=nl80211
ssid=$SSID
hw_mode=g
channel=6
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$PASSWORD
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOL

# Configure hostapd to use our config
sudo sed -i 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/' /etc/default/hostapd

# Configure dnsmasq
echo "Configuring dnsmasq..."
sudo cat > /etc/dnsmasq.conf << EOL
interface=wlan0
dhcp-range=192.168.1.50,192.168.1.150,12h
EOL

# Configure network interfaces
echo "Configuring network interfaces..."
sudo cat > /etc/systemd/network/08-wlan0.network << EOL
[Match]
Name=wlan0
[Network]
Address=192.168.1.1/24
IPMasquerade=yes
IPForward=yes
DHCPServer=yes
[DHCPServer]
DNS=1.1.1.1
EOL

# Enable IP forwarding
echo "Enabling IP forwarding..."
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo sysctl -p

# Configure NAT
echo "Configuring NAT..."
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
sudo iptables -A FORWARD -i wlan0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o wlan0 -j ACCEPT
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

# Add iptables restore on boot
sudo sed -i '/exit 0/i iptables-restore < /etc/iptables.ipv4.nat' /etc/rc.local

# Start services
echo "Starting services..."
sudo systemctl start hostapd
sudo systemctl start dnsmasq
sudo systemctl enable hostapd
sudo systemctl enable dnsmasq

echo "Setup complete! Rebooting..."
sleep 2
sudo reboot 