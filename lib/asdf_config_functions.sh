function __elixir() {
    Pkg unzip
    Pkg inotify-tools
}

function __golang() {
    Pkg coreutils
    Pkg curl
}

function __lua() {
    case $distro in
    arch)
        Pkg base-devel
        Pkg linux-headers
        ;;
    debian)
        Pkg linux-headers-$(uname -r)
        Pkg build-essential
        ;;
    esac
}

function __java() {
    case $distro in
    arch)
        Pkg bash
        Pkg curl
        Pkg coreutils
        Pkg unzip
        Pkg jq
        ;;
    debian)
        Pkg bash
        Pkg curl
        Pkg sha256sum
        Pkg unzip
        Pkg jq
        ;;
    esac
}

function __nodejs() {
    case $distro in
    arch)
        Pkg gcc
        Pkg make
        Pkg python
        Pkg python-pip
        ;;
    debian)
        Pkg g++
        Pkg make
        Pkg python3
        Pkg python3-pip
        ;;
    esac
}

function __python() {
    case $distro in
    arch)
        Pkg base-devel
        Pkg openssl
        Pkg zlib
        Pkg xz
        Pkg tk
        ;;
    debian)
        Pkg build-essential
        Pkg libssl-dev
        Pkg zlib1g-dev
        Pkg libbz2-dev
        Pkg libreadline-dev
        Pkg libsqlite3-dev
        Pkg curl
        Pkg git
        Pkg libncursesw5-dev
        Pkg xz-utils
        Pkg tk-dev
        Pkg libxml2-dev
        Pkg libxmlsec1-dev
        Pkg libffi-dev
        Pkg liblzma-dev
        ;;
    esac
}

function __php() {
    case $distro in
    arch)
        Pkg autoconf
        Pkg bison
        Pkg base-devel
        Pkg curl
        Pkg gettext
        Pkg git
        Pkg gd
        Pkg libcurl-compat
        Pkg libedit
        Pkg icu
        Pkg libjpeg-turbo
        Pkg mariadb-libs
        Pkg oniguruma
        Pkg libpng
        Pkg postgresql-libs
        Pkg readline
        Pkg sqlite
        Pkg openssl
        Pkg libxml2
        Pkg libzip
        Pkg pkgconf
        Pkg re2c
        Pkg zlib
        ;;
    debian)
        Pkg autoconf
        Pkg bison
        Pkg build-essential
        Pkg curl
        Pkg gettext
        Pkg git
        Pkg libgd-dev
        Pkg libcurl4-openssl-dev
        Pkg libedit-dev
        Pkg libicu-dev
        Pkg libjpeg-dev
        Pkg libmysqlclient-dev
        Pkg libonig-dev
        Pkg libpng-dev
        Pkg libpq-dev
        Pkg libreadline-dev
        Pkg libsqlite3-dev
        Pkg libssl-dev
        Pkg libxml2-dev
        Pkg libzip-dev
        Pkg openssl
        Pkg pkg-config
        Pkg re2c
        Pkg zlib1g-dev
        ;;
    esac
}

function __ruby() {
    case $distro in
    arch)
        Pkg base-devel
        Pkg rust
        Pkg libffi
        Pkg libyaml
        Pkg openssl
        Pkg zlib
        ;;
    debian)
        Pkg autoconf
        Pkg patch
        Pkg build-essential
        Pkg rustc
        Pkg libssl-dev
        Pkg libyaml-dev
        Pkg libreadline6-dev
        Pkg zlib1g-dev
        Pkg libgmp-dev
        Pkg libncurses5-dev
        Pkg libffi-dev
        Pkg libgdbm6
        Pkg libgdbm-dev
        Pkg libdb-dev
        Pkg uuid-dev
        ;;
    esac
}

function __erlang() {
    case $distro in
    arch)
        Pkg base-devel
        Pkg ncurses
        Pkg glu
        Pkg mesa
        Pkg wxwidgets-gtk3
        Pkg libpng
        Pkg libssh
        Pkg unixodbc
        Pkg libxslt
        Pkg fop
        ;;
    debian)
        case $distro_id in
        ubuntu)
            case $distro_version in
            24.04)
                Pkg build-essential
                Pkg autoconf
                Pkg m4
                Pkg libncurses5-dev
                Pkg libwxgtk3.2-dev
                Pkg libwxgtk-webview3.2-dev
                Pkg libgl1-mesa-dev
                Pkg libglu1-mesa-dev
                Pkg libpng-dev
                Pkg libssh-dev
                Pkg unixodbc-dev
                Pkg xsltproc
                Pkg fop
                Pkg libxml2-utils
                Pkg libncurses-dev
                Pkg openjdk-11-jdk
                ;;
            20.04 | 22.04)
                Pkg build-essential
                Pkg autoconf
                Pkg m4
                Pkg libncurses5-dev
                Pkg libwxgtk3.0-gtk3-dev
                Pkg libwxgtk-webview3.0-gtk3-dev
                Pkg libgl1-mesa-dev
                Pkg libglu1-mesa-dev
                Pkg libpng-dev
                Pkg libssh-dev
                Pkg unixodbc-dev
                Pkg xsltproc
                Pkg fop
                Pkg libxml2-utils
                Pkg libncurses-dev
                Pkg openjdk-11-jdk
                ;;
            16.04 | 18.04)
                Pkg build-essential
                Pkg autoconf
                Pkg m4
                Pkg libncurses5-dev
                Pkg libwxgtk3.0-dev
                Pkg libgl1-mesa-dev
                Pkg libglu1-mesa-dev
                Pkg libpng-dev
                Pkg libssh-dev
                Pkg unixodbc-dev
                Pkg xsltproc
                Pkg fop
                ;;
            *) ;;
            esac
            ;;
        *)
            Pkg build-essential
            Pkg autoconf
            Pkg m4
            Pkg libncurses-dev
            Pkg libwxgtk3.2-dev
            Pkg libwxgtk-webview3.2-dev
            Pkg libgl1-mesa-dev
            Pkg libglu1-mesa-dev
            Pkg libpng-dev
            Pkg libssh-dev
            Pkg unixodbc-dev
            Pkg xsltproc
            Pkg fop
            Pkg libxml2-utils
            Pkg openjdk-17-jdk
            ;;
        esac
        ;;
    esac

}

function __stylua() {
    Pkg bash
    Pkg curl
    Pkg unzip
}

function ASDFPluginDependency() {
    case $1 in
    elixir)
        __elixir
        ;;
    golang)
        __golang
        ;;
    lua)
        __lua
        ;;
    java)
        __java
        ;;
    nodejs)
        __nodejs
        ;;
    ruby)
        __ruby
        ;;
    python)
        __python
        ;;
    php)
        __php
        ;;
    erlang)
        __erlang
        ;;
    stylua)
        __stylua
        ;;
    esac
}

function ASDFPlugin() {
    ValidateFunctionParams 1 $# $FUNCNAME

    if command -v asdf &>/dev/null; then
        if ! asdf plugin list | grep $1 &>/dev/null; then
            asdf_plugins+=($1)
            ASDFPluginDependency $1
        fi
    else
        asdf_plugins+=($1)
        ASDFPluginDependency $1
    fi
}
