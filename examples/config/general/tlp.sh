Pkg tlp
Pkg tlp-rdw
Pkg smartmontools

SystemDirectory /etc/tlp.d/

SystemdUnitSystemEnable tlp.service
SystemdUnitSystemMask systemd-rfkill.service
SystemdUnitSystemMask systemd-rfkill.socket
