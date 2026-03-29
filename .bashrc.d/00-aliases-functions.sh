#!/bin/bash

##
## Aliases
##

alias k=kubectl
alias d=docker
alias vi=nvim
alias vim=nvim

# List files
alias lll='ls -alF'
alias ll='ls -ltrh'
alias la='ls -A'
alias l='ls -CF'
alias ls='ls -tr --color=auto'



alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../../'

alias claude-local="claude --settings ~/.claude/settings.json"

alias lower="tr '[:upper:]' '[:lower:]'"
alias upper="tr '[:lower:]' '[:upper:]'"

alias me="printf "$USER-";date +%Y/%m/%d-%I:%M:%S%p"

#alias bat="batcat --paging=never"

