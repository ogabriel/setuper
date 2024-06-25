#!/bin/bash

set -e

echo "Building package"
pacman -Sy base-devel --noconfirm --needed

echo "Entering build directory"
cd /build

echo "Setup user"
useradd --no-create-home build

echo "show passwd"
cat /etc/passwd

echo "Setting permissions"
chown -R build:build /build

echo "Setting permissions for everyone"
chmod -R 777 /build

echo "Switching to build user"
su build

echo "Current user is: $(whoami)"

echo "Building package"
makepkg
