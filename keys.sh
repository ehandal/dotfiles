#!/bin/sh
# depends xmodmap xcape
# https://github.com/alols/xcape

setxkbmap -option ctrl:nocaps
xcape -e '#66=Escape'

# assign return to control on press, return on release
xmodmap -e 'keycode 36 = 0x1234'
xmodmap -e 'add Control = 0x1234'
# make a fake return key (so we can map it with xcape)
xmodmap -e 'keycode any = Return'
xcape -e '0x1234=Return'
