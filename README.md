# Setupper

Aplication to handle everything related to your Arch Linux instalation

## Configuration

### Functions

- Pkg/Package - sets a package to be installed and managed
    - --AUR/--aur allows to specify the origin of the package
- User - creates the user and configures it, can be just used as `User $USER`
    - --groups - list of groups that user shall be added
    - --shell - user's shell
- Group - creates a group
- SystemdEnable - enables a systemd system unit
- SystemdEnableUser -enables a system user unit
- SystemdMask - masks a systemd system unit
- SystemFile - copies a system file with superuser permissions, like a udev rule, tlp config etc.
- SystemFileFromTo - same as SystemFile, but is used to rename the file from the name in your configs to a system name, mostly used if you're keeping configs for different systems
- UserFile - links a user file or folder, basically this shall be used for dotfiles, like `UserFile .conf/nvim` or `UserFile .zsh`
- UserFileFromTo - self explanatory
- SSHGen/SSHGenKey - generates a ssh key for params
    - --file - key file, like `.ssh/id_rsa_foobar`
    - --comment - for github this is your email
- SSHAdd/SSHAddKey - adds the key to your agent (idont know if this will world correctly)

### Execution order

The order is thought to not cause any problems, so for example, the packages will be installed first, so their relative units are available to be enabled and so on.

<!-- TODO: put order here -->

### bash

The config file is just a config file, so you can do everything you want, the main use of this feature will be something like have TLP only installed on your laptops.

## TODO
- [ ] handle users
- [ ] handle user's groups
- [ ] handle packages
- [ ] handle AUR packages
- [ ] handle systemd units
- [ ] handle system files
- [ ] handle properties for system files
- [ ] handle user files
- [ ] handle ssh keys creation
- [ ] handle ssh keys addition

## future features

- [ ] strict mode for more control over system
- [ ] allow to be run as root
- [ ] support for flatpak
- [ ] support for other package managers from other distros
- [ ] community configs to certain hardware (ex: nvidia)
- [ ] enable support for asdf

## Motivation, Inspirations and alternatives

I've been trying to have a self contained system for years, I've seem the strangest problems of driver corruption or a system getting old and you you re-install your system and forget how you made "that thing" work.

Even on windows i would try to write down how I made certain things work, when I started using linux, I would have the most extensive scripts to install everything to my liking, but every time I would forget how I made certain important thing work.

My previous tries, inspirations and alternatives to setupper:

- [https://github.com/ogabriel/setup](setup) - It's a collection of scripts that I've used for some years, and aren't ideal to manage a system
- [https://github.com/ogabriel/ricer](ricer) - A try at managing a system, but the go syntax was not write to write my configs down
- [https://github.com/ogabriel/ricer-lua](ricer-lua) - Lua serves as a way better config file and the compiled size of the static file with a include interpreter was smaller then the previous golang binary, but still, i was not happy and had some problems 
- [https://github.com/ogabriel/setup-rust](setup-rust) - Tried to recode everything in rust and with toml files, but got sick before starting the project. But even before starting I was not happy with the toml for configuration files and I also started to look at the pkl config language, which have "if" that could be used for configs, but didn't find rust parsers that could be properly used
- [https://github.com/CyberShadow/aconfmgr](aconfmgr) - My biggest inspiration! The thought of using bash to implement the application and the config files had crossed my mind at some point, but I never trusted that it could be really used on a day-to-day basis. But I decided to give it a chance, and installed it, ran `aconfmgr save` and a couple minutes later I had a system managed by config files, some more couple hours and some "ifs" and I had two of my machines fully managed. But the problem was that some aspects of it were not covered, like systemd units, user groups, dotfiles etc. which are not a deal breaker, but are important to the things I use and I wanted to be managed by it. So I started this project! PS: the reason I didn't contribute to aconfmgr directly was mostly that I wanted to learn more about bash starting my own project.
- NixOS - probably the most complete managed system out there, but for what I read it has some problems when setting up uncoved things. Also I didn't like the way to manage multiple systems on it (e.g desktop, laptop)
