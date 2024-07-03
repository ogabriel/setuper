# opengl
Pkg mesa
Pkg lib32-mesa
Pkg mesa-utils

# Vulkan
Pkg vulkan-radeon
Pkg lib32-vulkan-radeon

# HW acceleration
Pkg libva-mesa-driver
Pkg lib32-libva-mesa-driver
Pkg mesa-vdpau
Pkg lib32-mesa-vdpau

SystemFile /etc/profile.d/amdgpu-hw.sh

if [[ $XDG_SESSION_TYPE == 'x11' ]]; then
    Pkg xf86-video-amdgpu
fi
