# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
if [ -f ~/.local/share/omarchy/default/bash/rc ]; then
    source ~/.local/share/omarchy/default/bash/rc
fi

# Add your own exports, aliases, and functions here.

#setxkbmap -option "ctrl:nocaps"


#
## bash shell colors and styles.
# Use with 'echo -e "${bcred}${bsbold}${bsblink} ERROR ${bereset}${bcwhite}${bgblack}: An error has occurred.${bereset}'
#
# Font (foreground) Colors
export bcgreen='\e[0;32m'
export bcred='\e[0;31m'
export bcblack='\e[0;30m'
export bcblue='\e[0;34m'
export bcwhite='\e[0;37m'
# Font background Colors
export bgcblack='\e[0;40m'
export bgcwhite='\e[0;47m'
# effects
export bereset='\e[0;0m'
# styles
export bsbold='\e[0;1m'
export bsdim='\e[0;2m'
export bsunderline='\e[0;4m'
export bsblink='\e[0;5m'
#
## end bash colors and styles.
#

if [ -d ~/.bashrc.d ]; then
  for SHELL_FU in ~/.bashrc.d/*.sh; do 
    source ${SHELL_FU}
  done
fi

