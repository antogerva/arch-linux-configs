#!/bin/sh
#
# ~/.xinitrc
# Executed by startx (run your window manager from here)
xrdb -merge $HOME/.Xresources &
xmodmap $HOME/.Xmodmap &
xbindkeys &
xsetroot -bg black -cursor_name left_ptr &
nvidia-settings --load-config-only &
urxvtd -q -o -f &
# parcellite &
# D-bus
if which dbus-launch >/dev/null && test -z "$DBUS_SESSION_BUS_ADDRESS"; then
       eval `dbus-launch --sh-syntax --exit-with-session`
fi
exec awesome > $HOME/.awesome.log 2>&1
