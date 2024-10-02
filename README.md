# Setuper

Aplication to handle everything related to your system and dotfiles!

## Support

Most arch and debian based distros should work fine.

## Instalation

Go to the release page and download the debian or arch package. Or use one of these commands:

Arch based:

```bash
wget https://github.com/ogabriel/setuper/releases/latest/download/setuper.pkg.tar.zst && sudo pacman -U setuper.pkg.tar.zst && rm setuper.pkg.tar.zst
```

Debian based:

```bash
wget https://github.com/ogabriel/setuper/releases/latest/download/setuper.deb && sudo dpkg -i setuper.deb && rm setuper.deb
```

## Configuration

### Paths

The default path for the config is on `$HOME/.config/setuper/`

And inside that you can have three folders with the files to be used:
- `./system` - for the system files and directories, these files will be copied to your system with the `sudo` command
    - it's not a link because it's not really recommended to use links from user files to root
- `./user` - user files and directories, will be soft linked to your files
    - these files should be mostly the dotfiles
- `./packages` - from your sourced files

you can also define custom locations to these files with a `$HOME/.config/setuper/config.sh`, like:

```bash
system_files_dir=$HOME/.system/
user_files_dir=$HOME/.dotfiles/
sourced_package_dir=$HOME/.mypackages/
```

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
    - `--version=version_name/latest` - install that specific version
    - `--global` - auto installs that version as global

### Execution order

The order is thought to not cause any problems, so for example, the packages will be installed first, so their relative units are available to be enabled and so on.

<!-- TODO: put order here -->

### Sourcing order

When loading the configuration files, the file `config.sh` will be sourced first, and then the rest by alphabetical order

### Examples of configurations

The config file is just a bash file, so you can do everything you want in different hosts or different package managers.

Inside the folder `examples` of this repository you can find many scripts of setting up things (mainly on arch).

You cam copy the entire folder to your config folder, as `setuper` will not source files inside folders, you will have to source the ones you need.

#### Using conditionals

The main use of conditionals will be having different configurations on each PC:

```bash
if [[ "$HOSTNAME" == "laptop" ]]; then
    # something only on laptop
fi
```

Sometimes you want to define a variable to be used on other files, so you can set a variable on the `config.sh` to be later used:

```bash
# on the config.sh file
case $HOSTNAME in
my_work_PC)
    window_manager=sway
    ;;
my_personal_PC)
    window_manager=hyprland
    ;;
esac

# on another file
case $window_manager in
sway)
    Pkg sway
    # ...
    ;;
esac
```

### Manage configuration

It's recommended to use `setuper` inside a git repository

#### dotfiles

If you already has a dotfiles repository you can add it to the `setuper` repository in three ways:

- git submodules - you can track your dotfiles changes inside a submodule, it may cause some headaches, as submodules are kinda hard to manage
    - `git submodule add git@github.com:myuser/dotfiles.git user`
- git subtree - it's more flexible then submodules
    - `git remote add dotfiles-remote git@github.com:myuser/dotfiles.git`
    - `git subtree add --prefix user dotfiles-remote main`
- .gitignore - just clone your dotfiles repository and add it to your .gitignore
    - `git clone git@github.com:myuser/dotfiles.git user`
    - `echo user >> .gitignore`

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
- [ ] allow to be run as root
- [ ] add a way to use transactions/checksums to avoid doing too much work
- [ ] add way to download the package on other places, like a ppa and on AUR
- [ ] add options to be less strict and dont ask as many questions

## Motivation, Inspirations and alternatives

I've been trying to have a self contained system for years, I've seem the strangest problems of driver corruption or a system getting old and you you re-install your system and forget how you made "that thing" work.

Even on windows i would try to write down how I made certain things work, when I started using linux, I would have the most extensive scripts to install everything to my liking, but every time I would forget how I made certain important thing work.

And as I was migrating all my PCs to archlinux, it was a chore to configure everything manually.

My previous tries, inspirations and alternatives to setuper:

- [setup](https://github.com/ogabriel/setup) - It's a collection of scripts that I've used for some years, and aren't ideal to manage a system
- [ricer](https://github.com/ogabriel/ricer) - A try at managing a system, but the go syntax was not write to write my configs down
- [ricer-lua](https://github.com/ogabriel/ricer-lua) - Lua serves as a way better config file and the compiled size of the static file with a include interpreter was smaller then the previous golang binary, but still, i was not happy and had some problems
- [setup-rust](https://github.com/ogabriel/setup-rust) - Tried to recode everything in rust and with toml files, but got sick before starting the project. But even before starting I was not happy with the toml for configuration files and I also started to look at the pkl config language, which have "if" that could be used for configs, but didn't find rust parsers that could be properly used
- [aconfmgr](https://github.com/CyberShadow/aconfmgr) - My biggest inspiration! The thought of using bash to implement the application and the config files had crossed my mind at some point, but I never trusted that it could be really used on a day-to-day basis. But I decided to give it a chance, and installed it, ran `aconfmgr save` and a couple minutes later I had a system managed by config files, some more couple hours and some "ifs" and I had two of my machines fully managed. But the problem was that some aspects of it were not covered, like systemd units, user groups, dotfiles etc. which are not a deal breaker, but are important to the things I use and I wanted to be managed by it. So I started this project! PS: the reason I didn't contribute to aconfmgr directly was mostly that I wanted to learn more about bash starting my own project.
- [NixOS](https://nixos.org/) - probably the most complete managed system out there, but for what I read it has some problems when setting up uncoved things. Also I didn't like the way to manage multiple systems on it (e.g desktop, laptop). Also there is this issue that NixOS is not FHS compliant, which for me is not a big deal, but it might be in the future.
