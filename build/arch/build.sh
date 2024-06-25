#!/bin/bash

pacman -Sy base-devel --noconfirm --needed
cd /build
useradd --no-create-home --shell=/bin/false build
chown -R build:build /build
chmod -R 777 /build
su build -c "makepkg"
