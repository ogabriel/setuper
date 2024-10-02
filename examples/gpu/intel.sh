# opengl
Pkg mesa
Pkg lib32-mesa

# HW acceleration
Pkg intel-media-driver

# vulkan
Pkg vulkan-intel
Pkg lib32-vulkan-intel

SystemFile /etc/modprobe.d/i915.conf
SystemFile /etc/udev/rules.d/80-i915.rules
SystemFile /usr/local/bin/intel-wayland-fix-full-color

if [[ $XDG_SESSION_TYPE == 'x11' ]]; then
    Pkg xf86-video-intel
else
    RemovePkg xf86-video-intel
fi
