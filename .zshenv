#!/bin/zsh
#

# Dircolors...
eval `dircolors -b ~/.dircolors`

# Exports
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/home/stxza/bin
export LC_ALL=en_AU.UTF-8
export LANG=en_AU.UTF-8
export LOCALE=en_AU.UTF-8
export EDITOR=vim
export BROWSER=swiftweasel
export OOO_FORCE_DESKTOP=gnome
export HISTCONTROL=ignoredups

# Make framebuffer colors look like in X
if [ "$TERM" = "linux" ]; then
    echo -en "\e]P0222222" #black
    echo -en "\e]P8222222" #darkgrey
    echo -en "\e]P1803232" #darkred
    echo -en "\e]P9982b2b" #red
    echo -en "\e]P25b762f" #darkgreen
    echo -en "\e]PA89b83f" #green
    echo -en "\e]P3aa9943" #brown
    echo -en "\e]PBefef60" #yellow
    echo -en "\e]P4324c80" #darkblue
    echo -en "\e]PC2b4f98" #blue
    echo -en "\e]P5706c9a" #darkmagenta
    echo -en "\e]PD826ab1" #magenta
    echo -en "\e]P692b19e" #darkcyan
    echo -en "\e]PEa1cdcd" #cyan
    echo -en "\e]P7ffffff" #lightgrey
    echo -en "\e]PFdedede" #white
    clear #for background artifacting
fi
