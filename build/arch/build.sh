#!/bin/bash

echo "Building package"
pacman -Sy base-devel --noconfirm --needed

echo "Entering build directory"
cd /build

echo "Setup user"
useradd --no-create-home --shell=/bin/false build

echo "Setting permissions"
chown -R build:build /build

echo "Setting permissions for everyone"
chmod -R 777 /build

echo "Build package"
su build -c "makepkg"
