#!/bin/sh
#
# ~/.xinitrc
# Executed by startx (run your window manager from here)
xrdb -merge $HOME/.Xresources &
nvidia-settings --load-config-only &
xsetroot -cursor_name left_ptr -solid "#090909" &
xmodmap $HOME/.Xmodmap &
xbindkeys &
urxvtd -o -q -f &
parcellite &
exec awesome > $HOME/.awesome.log 2>&1
