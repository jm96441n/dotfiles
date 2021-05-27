xrbd -merge ~/.Xresources
# Turn off caps lock for ctrl
setxkbmap -option "ctrl:nocaps"
# Set mouse speed
xinput set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Accel Speed' 1.0
# set keyboard repeate rate
xset r rate 200 25
exec i3
