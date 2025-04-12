#!/bin/bash

# Create packages directory
mkdir -p packages

# Download packages and their dependencies
apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances hostapd dnsmasq | grep "^\w" | sort -u)

# Move all .deb files to packages directory
mv *.deb packages/

echo "Packages downloaded to packages/ directory" 