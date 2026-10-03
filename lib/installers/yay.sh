Info "Installing yay"

sudo pacman -S --needed $pacman_noconfirm git base-devel
cd /tmp
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
