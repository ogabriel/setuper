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
