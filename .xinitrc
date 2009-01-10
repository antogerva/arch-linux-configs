#!/bin/sh
#
# ~/.xinitrc
# Executed by startx (run your window manager from here)
# xrdb -load $HOME/.Xdefaults &
xrdb -merge $HOME/.Xresources &
xmodmap $HOME/.Xmodmap &
xbindkeys &
xsetroot -cursor_name left_ptr -solid "#090909" &
nvidia-settings --load-config-only &
urxvtd -o -q -f &
parcellite &
exec awesome > $HOME/.awesome.log 2>&1
