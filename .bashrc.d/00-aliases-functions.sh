#!/bin/bash

##
## Aliases
##

alias k=kubectl
alias d=docker
alias g=git
alias vi=nvim
alias vim=nvim

# List files
LS_OPTS="-r --color=auto --group-directories-first --human-readable --dereference "
export LS_OPTS
alias lll='ls ${LS_OPTS} -alF'
alias ll='ls ${LS_OPTS} -ltrh'
alias la='ls ${LS_OPTS} -A'
alias l='ls ${LS_OPTS} -CF'
alias ls='ls ${LS_OPTS} -tr --color=auto'



alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../../'

alias claude-local="claude --settings ~/.claude/settings.json"

alias lower="tr '[:upper:]' '[:lower:]'"
alias upper="tr '[:lower:]' '[:upper:]'"

alias me="printf "$USER-";date +%Y/%m/%d-%I:%M:%S%p"
alias datelog='date +%m-%d-%Y-%H-%M-%S'

# Forward SSH Agent socket over tunnel to enable key access on target machine.
alias ssh='sshagenthelper && /usr/bin/ssh '
alias scp='sshagenthelper && /usr/bin/scp '
alias ssh-add='sshagenthelper && /usr/bin/ssh-add '
alias ssh-agent='sshagenthelper'

# Debug helper
function debugecho() {
    if [ ! -z "${DEBUG}" ]; then
	echo "INFO: ${1}"
    fi
}

# If bat is install, alias cat to use bat.
if command -v /usr/bin/bat > /dev/null ; then
    alias cat='bat'
    alias bat="bat -p --paging=never"
fi

# Superfile CLI/TUI file explorer
    function spf() {
        os=$(uname -s)
        # Linux
        if [[ "$os" == "Linux" ]]; then
            export SPF_LAST_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir"
        fi
        # macOS
        if [[ "$os" == "Darwin" ]]; then
            export SPF_LAST_DIR="$HOME/Library/Application Support/superfile/lastdir"
        fi

        command spf "$@"

        [ ! -f "$SPF_LAST_DIR" ] || {
            . "$SPF_LAST_DIR"
            rm -f -- "$SPF_LAST_DIR" > /dev/null
        }
    }
