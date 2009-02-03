#!/bin/sh

# xresources
xrdb -merge $HOME/.Xresources &

# wall
feh --bg-scale ~/Pictures/Walls/CalmSkies.jpg &

# Trayer icon tray -> try different heights
trayer --edge top --align right --SetDockType true --SetPartialStrut true \
--expand true --width 4 --transparent true --tint 0x000000 --alpha 0 --distance 0 --padding 0 --heighttype pixel --height 16 &

# keys & cursor
xmodmap $HOME/.Xmodmap &
xbindkeys &
xsetroot -cursor_name left_ptr &

# nvidia settings
nvidia-settings --load-config-only &

# apps
parcellite &
urxvtd -q -o -f &

# D-bus -> fixed in xmonad-darcs?
if which dbus-launch >/dev/null && test -z "$DBUS_SESSION_BUS_ADDRESS"; then
       eval `dbus-launch --sh-syntax --exit-with-session`
fi
exec xmonad > $HOME/.xmonad.log 2>&1
