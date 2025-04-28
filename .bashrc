##
## Shell configurations and options.
##


# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

##
## History file setup
##
## See https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
#
# Set history file to include timestamp
export HISTTIMEFORMAT="%h/%d - %H:%M:%S "
# Define number of records to keep in history file
export HISTFILESIZE=100000
# HISTFILE to use for appending history properly.
export HISTFILE=${HOME}/.peekaboo
# Append commands to history file instead of clobbering.
shopt -s histappend
# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth


## https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
# Check window size when spawning.
shopt -s checkwinsize
## Terminal Emulator Settings
export TERM=xterm-color








# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac



##
## Aliases
##

alias ssh='ssh -q -q'
alias ls='ls -tr --color=auto'
alias lower="tr '[:upper:]' '[:lower:]'"
alias upper="tr '[:lower:]' '[:upper:]'"
alias who='who | awk "{print \$1}" | sort -u'
alias me="printf "$USER-";date +%Y/%m/%d-%I:%M:%S%p"
alias bat="batcat --paging=never"
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias d='docker'
alias k='kubectl'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'


# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi


#
# Use bash completion everywhere!
#
BASH_COMPLETION_FILES=("/etc/profile.d/bash_completion.sh" "/etc/bash_completion")
for BCFILE in ${BASH_COMPLETION_FILES[@]}; do
    if [ -f "${BCFILE}" ]; then
        source ${BCFILE}
    fi
done


##
## Kubernetes commands, aliases, helpers
##

function kubernetes() {
    # The local home directory setup for kubectl auth config
    export KUBECONFIG=$HOME/.kube/config

#    source /etc/bash_completion
    alias k=kubectl
    source <(kubectl completion bash)
    complete -F __start_kubectl k

    alias k=kubectl
    complete -o default -F __start_kubectl k
    alias kx='f() { [ "$1" ] && k config use-context $1 || k config current-context ; } ; f'
    alias kn='f() { [ "$1" ] && k config set-context --current --namespace $1 || k config view --minify | grep namespace | cut -d" " -f6 ; } ; f'
    alias kexec='f() { k exec -ti $1 -- /bin/bash ; } ; f'
    alias kall='f() { k get all ; } ; f'
    alias kdesc='f() { k describe $1 ; } ; f'
    alias kkill='f() { k delete $1 --force --grace-period=0 ; } ; f'
    PS1="\u@\$(kx) [\$(kn)] \w> "
}
##
## Kubernetes commands, aliases, helpers
##

function kubernetes() {
    # Kubernetes cluster info
    KUBEBIN_PATH=/home/msnow/bin
    if [ -d $KUBEBIN_PATH ]; then
      export PATH=${KUBEBIN_PATH}:${PATH}
    fi

    # The local home directory setup for kubectl auth config
    if [ -e $HOME/.kube/config ]; then
      export KUBECONFIG=$HOME/.kube/config
    fi

    alias k=kubectl
    source <(kubectl completion bash)
    complete -F __start_kubectl k
    complete -o default -F __start_kubectl k

    alias kx='f() { [ "$1" ] && k config use-context $1 || k config current-context ; } ; f'
    alias kn='f() { [ "$1" ] && k config set-context --current --namespace $1 || k config view --minify | grep namespace | cut -d" " -f6 ; } ; f'
    alias kexec='f() { k exec -ti $1 -- /bin/bash ; } ; f'
    alias kall='f() { k get all ; } ; f'
    alias kdesc='f() { k describe $1 ; } ; f'
    alias kkill='f() { k delete $1 --force --grace-period=0 ; } ; f'
    PS1="\u@\$(kx) [\$(kn)] \w> "
}

function kimages() {
  k get pods --all-namespaces -o jsonpath="{.items[*].spec['initContainers', 'containers'][*].image}" | tr -s '[[:space:]]' '\n' | sort | uniq -c
}


##
## Sops and Age
##
export SOPS_AGE_RECIPIENTS=$( cat ~/.sops/age/age.pub )
if [ -f ~/.sops/age/age.key ]; then
  export SOPS_AGE_KEY_FILE=~/.sops/age/age.key
fi



##
## SSH command helpers
##

function sshhostkeyclean() {
  unset RMHOSTS
  RMHOST=$1
  echo RMHOST is $RMHOST
  echo 1 is $1
  if [[ $RMHOST =~ [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]]; then
    echo "given an IP address."
    RMHOSTIP=$RMHOST
    RMHOSTFQDN=$(/bin/host ${RMHOSTIP} | awk '{print $5}' | cut -d. -f1,2,3)
    RMHOSTNAME=$(echo ${RMHOSTFQDN} | cut -d. -f1)
  elif [[ $RMHOST =~ (x[a-z]{3,10}|x[a-z]{5,}[0-9].*)$ ]]; then
    echo "given a short hostname"
    RMHOSTNAME=${RMHOST}
    RMHOSTFQDN=$(/bin/host ${RMHOSTNAME} | awk '{print $1}')
    RMHOSTIP=$(/bin/host ${RMHOSTNAME} | awk '{print $4}')
  elif [[ $RMHOST =~ (x[a-z]{3,10}|x[a-z]{5,}[0-9].*)\.(com|net|org|io|us)$ ]]; then
    echo "given a FQDN"
    RMHOSTFQDN=$RMHOST
    RMHOSTNAME=$(echo ${RMHOSTFQDN} | cut -d. -f1)
    RMHOSTIP=$(/bin/host ${RMHOSTIP} | awk '{print $4}')
  fi
  RMHOSTS=(${RMHOSTIP} ${RMHOSTNAME} ${RMHOSTFQDN})
  echo "all hosts are ${RMHOSTS[@]}"
  for entry in ${RMHOSTS[@]}; do
    ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "$entry";
  done
}

function ssh-add-my-local() {
    FSTYPE=$(stat --file-system --format=%T ${HOME}/.ssh/)
    if [[ "$FSTYPE" != "nfs" ]]; then
      ssh-add -t 604800 ${HOME}/.ssh/id_ed25519
    fi
}

function ssh_set_vars() {
  if [ -f ${HOME}/.ssh/ssh-agent.env ]; then
    source ${HOME}/.ssh/ssh-agent.env
  else
    echo "${HOME}/.ssh/ssh-agent.env not found"
  fi
}




##
## TLS / x509 helpers
##
function tls_check_cert_expiration() {
  if [ ${#1} -lt 1 ]; then
    echo "Use openssl to get the certificate validation dates beginning and expiring, information provided a hostname:portnumber. e.g. google.com:443"
  fi
  echo "QUIT" | openssl s_client -connect ${1} -showcerts 2>/dev/null | openssl x509 -inform pem -noout -text | grep -A2 'Validity' | grep -v Validity
}

function tls_get_cert() {
  if [ ${#1} -lt 1 ]; then
    echo "This shell function runs openssl to get the certificate information provided a hostname:portnumber. e.g. google.com:443"
  fi
  echo "QUIT" | openssl s_client -connect ${1} -showcerts 2>/dev/null | openssl x509 -inform pem -noout -text
}




###
### Must have fzf - this is a game changer and must have! https://github.com/junegunn/fzf
###
# fzf - shell fuzzy finder
#
# See https://github.com/junegunn/fzf
#
if [ $(which fzf) ]; then
  export FZF_DEFAULT_OPTS="--height=-50%"
  #
  # Theme for fzf - https://vitormv.github.io/fzf-themes/
  # COLORS
  export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS' --color=fg:#d0d0d0,fg+:#d0d0d0,bg:#121212,bg+:#262626 --color=hl:#5f87af,hl+:#5fd7ff,info:#afaf87,marker:#87ff00 --color=prompt:#d7005f,spinner:#af5fff,pointer:#af5fff,header:#87afaf --color=border:#262626,label:#aeaeae,query:#d9d9d9'
  # DECORATE BORDERS
  export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS' --border=rounded --border-label="fzf" --preview-window=border-rounded'
  # DECORATE PROMPT AND CURSOR
  export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS' --prompt="> "  --marker=">" --pointer="◆" --separator="─" --scrollbar="│"'
  # Execute
  eval "$(fzf --bash )"
fi
# End fzf config
