Pkg nvidia
Pkg nvidia-utils
Pkg lib32-nvidia-utils

# utils
Pkg nvidia-settings
Pkg nvidia-prime

# HW video decoding
Pkg libva-nvidia-driver

# configs
SystemFile /etc/udev/rules.d/80-nvidia-pm.rules
SystemFile /etc/profile.d/nvidia.sh
SystemFile /etc/modprobe.d/10-nvidia-drm.conf
SystemFile /etc/modprobe.d/20-nvidia.conf
SystemFile /etc/pacman.d/hooks/nvidia.hook
SystemFile /etc/mkinitcpio.conf

# https://wiki.archlinux.org/title/PRIME#For_open_source_drivers_-_PRIME
SystemdUnitSystemEnable nvidia nvidia-persistenced.service

# https://wiki.archlinux.org/title/NVIDIA/Tips_and_tricks#Preserve_video_memory_after_suspend
SystemdUnitSystemEnable nvidia nvidia-suspend.service
