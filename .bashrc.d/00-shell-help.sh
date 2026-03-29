#!/bin/bash

##
## Extra Path stuff
##


# opencode
OPENCODE_BIN=/home/msnow/.opencode/bin
# Cargo
CARGO_BIN=/home/msnow/.cargo/bin
# uv
UV_PATH=/home/msnow/.local/bin

export PATH=${OPENCODE_BIN}:${CARGO_BIN}:${UV_PATH}:${PATH}





###
### fzf - shell fuzzy finder https://github.com/junegunn/fzf
###

if [ $(command -v fzf > /dev/null ]; then
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
#
