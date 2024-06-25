#!/bin/bash

pacman -Sy base-devel --noconfirm --needed
cd /build
makepkg
