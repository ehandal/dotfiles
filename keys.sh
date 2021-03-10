#!/bin/sh
# depends xmodmap xcape
# https://github.com/alols/xcape
set -e

setxkbmap -layout us -option # reset layout and options
killall -q xcape || true # prevent multiple active xcapes

setxkbmap -option ctrl:nocaps # CapsLock as Ctrl
xcape -e '#66=Escape' # keycode 66 is CapsLock

setxkbmap -option shift:both_capslock # both shifts together toggle capslock
setxkbmap -option terminate:ctrl_alt_bksp # ctrl+alt+backspace to kill X server

# assign Return to Control on press, Return on release
xmodmap -e 'clear Lock'
xmodmap -e 'clear Control'
xmodmap -e 'keycode 36 = Control_R' # keycode 36 is Enter
xmodmap -e 'keycode any = Return' # make a fake return key (so we can map it with xcape)
xmodmap -e 'add Control = Control_L Control_R'
xcape -e '#36=Return'
