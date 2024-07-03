# opengl
Pkg mesa
Pkg lib32-mesa

# HW acceleration
Pkg intel-media-driver

# vulkan
Pkg vulkan-intel
Pkg lib32-vulkan-intel

SystemFile /etc/modprobe.d/i915.conf
# fixes for 10 bit on wayland, fill the commands with the results from this command:
# proptest -M i915 -D /dev/dri/card0 | grep -E 'Broadcast|Connector'
SystemFile /etc/udev/rules.d/80-i915.rules

if [[ $XDG_SESSION_TYPE == 'x11' ]]; then
    Pkg xf86-video-intel
else
    RemovePkg xf86-video-intel
fi
