# Setuper

Aplication to handle everything related to your system and dotfiles!

## Support

Most arch and debian based distros should work fine.

## Configuration

### Functions

- `User username`- creates the user and configures it, can be just used as `User $USER`
    - `--groups` - list of groups that user shall be added
    - `--shell` - user's shell
- `Group groupname` - creates a group
- `Pkg/Package packagename` - sets a package to be installed and managed
    - `--AUR/--aur` allows to specify the origin of the package
    - `--group` - group packages for arch linux
    - `--flatpak` - flatpak packages
    - `--source=file` - this allows you to install a specific package in your config directories, like a `pkg.tar.zst` or `deb`, the file must be in the folder `packages/file`
- `RemovePkg/RemovePackage packagename` - removes said package
- `SystemdUnitSystemEnable unitname` - enables a systemd system unit
- `SystemdUnitSystemMask unitname` - masks a systemd system unit
- `SystemdUnitUserEnable unitname` -enables a system user unit
- `SystemFile file` - copies a system file with superuser permissions, like a udev rule, tlp config etc.
- `SystemFileFromTo from_file to_file` - same as above, but you can rename
- `SystemDirectory directory` - copies a directory like `system/etc/sddm.conf.d` to `/etc/sddm.conf.d`
- `SystemDirectoryFromTo from_directory to_directory` - same as above, but you can rename
- `UserFile file` - links a user file, basically this shall be used for dotfiles, like `UserFile .zsh`
- `UserFileFromTo from_file to_file` - same as above, but you can rename
- `UserDirectory directory` - use it like `UserDirectory .conf/nvim`, so your nvim configs inside the folder `users/.config/nvim` will be linked to `~/.config/nvim`
- `UserDirectoryFromTo from_directory to_directory` - same as above, but you can rename
- `SSHGenKey` - generates a ssh key for params
    - `--file` - key file, like `id_rsa_foobar`
    - `--comment` - comment for the key, for github this is your email
- `SSHAddKey` - adds the key to your agent (idont know if this will world correctly)
- `ASDFPlugin pluginname` - allows to install asdf automatically on your distro and handle specific dependencies for each plugin - each language has its specifc dependencies for each language and for each distro, so this function handles all that for you

### Execution order

The order is thought to not cause any problems, so for example, the packages will be installed first, so their relative units are available to be enabled and so on.

<!-- TODO: put order here -->

### Examples of config

The config file is just a bash file, so you can do everything you want in different hosts or different package managers.

#### TLP

The main use of this feature will be something like have TLP only installed on your laptops:

```bash
if [[ "$HOSTNAME" == "laptop" ]]; then
    Pkg tlp
    Pkg tlp-rdw
    Pkg smartmontools

    SystemDirectory /etc/tlp.d/

    SystemdUnitSystemEnable tlp.service
    SystemdUnitSystemMask systemd-rfkill.service
    SystemdUnitSystemMask systemd-rfkill.socket
fi
```

#### Docker

Some packages require some configuration that are not done automatically, like docker, that needs you to install the package, add your user to the group and then enable the service

```bash
Pkg docker

User $USER --groups=wheel,docker

SystemdUnitSystemEnable docker.service
```

#### Different window managers

Sometimes you want to try out a new WM only on your personal PC, so you can do something like this:

```bash
case $HOSTNAME in
my_work_PC)
    window_manager=sway
    ;;
my_personal_PC)
    window_manager=hyprland
    ;;
esac

case $window_manager in
sway)
    RemovePkg xdg-desktop-portal-hyprland
    RemovePkg xdg-desktop-portal-gnome
    RemovePkg xdg-desktop-portal-kde

    Pkg sway
    Pkg xdg-desktop-portal-wlr

    UserDirectory .config/sway
    ;;
hyprland)
    RemovePkg xdg-desktop-portal-wlr
    RemovePkg xdg-desktop-portal-gnome
    RemovePkg xdg-desktop-portal-kde

    Pkg hyprland
    Pkg xdg-desktop-portal-hyprland

    UserDirectory .config/hypr
    ;;
esac
```

## Features

- [X] handle users
- [X] handle user's groups
- [X] handle packages
- [X] handle AUR packages
- [X] handle systemd units
- [X] handle system files
- [X] handle system directories
- [X] handle properties for system files
- [X] handle user files
- [X] handle system directories
- [X] handle ssh keys creation
- [X] handle ssh keys addition
- [X] support for other package managers from other distros
    - pacman/yay
    - apt-get
- [X] support for the user sourcing a file to install a package (ex: .deb files)
- [X] support for flatpak packages
- [X] support for asdf plugins

### Future

- [ ] add unit tests - right now the project only works through hope
- [ ] strict mode for more control over system
- [ ] enable support for asdf
- [ ] allow to be run as root
- [ ] community configs to certain hardware (ex: nvidia)
- [ ] add a way to use transactions/checksums to avoid doing too much work

## Motivation, Inspirations and alternatives

I've been trying to have a self contained system for years, I've seem the strangest problems of driver corruption or a system getting old and you you re-install your system and forget how you made "that thing" work.

Even on windows i would try to write down how I made certain things work, when I started using linux, I would have the most extensive scripts to install everything to my liking, but every time I would forget how I made certain important thing work.

My previous tries, inspirations and alternatives to setuper:

- [setup](https://github.com/ogabriel/setup) - It's a collection of scripts that I've used for some years, and aren't ideal to manage a system
- [ricer](https://github.com/ogabriel/ricer) - A try at managing a system, but the go syntax was not write to write my configs down
- [ricer-lua](https://github.com/ogabriel/ricer-lua) - Lua serves as a way better config file and the compiled size of the static file with a include interpreter was smaller then the previous golang binary, but still, i was not happy and had some problems
- [setup-rust](https://github.com/ogabriel/setup-rust) - Tried to recode everything in rust and with toml files, but got sick before starting the project. But even before starting I was not happy with the toml for configuration files and I also started to look at the pkl config language, which have "if" that could be used for configs, but didn't find rust parsers that could be properly used
- [aconfmgr](https://github.com/CyberShadow/aconfmgr) - My biggest inspiration! The thought of using bash to implement the application and the config files had crossed my mind at some point, but I never trusted that it could be really used on a day-to-day basis. But I decided to give it a chance, and installed it, ran `aconfmgr save` and a couple minutes later I had a system managed by config files, some more couple hours and some "ifs" and I had two of my machines fully managed. But the problem was that some aspects of it were not covered, like systemd units, user groups, dotfiles etc. which are not a deal breaker, but are important to the things I use and I wanted to be managed by it. So I started this project! PS: the reason I didn't contribute to aconfmgr directly was mostly that I wanted to learn more about bash starting my own project.
- [NixOS](https://nixos.org/) - probably the most complete managed system out there, but for what I read it has some problems when setting up uncoved things. Also I didn't like the way to manage multiple systems on it (e.g desktop, laptop). Also there is this issue that NixOS is not FHS compliant, which for me is not a big deal, but it might be in the future.
