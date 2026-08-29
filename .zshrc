

autoload -Uz compinit && compinit -i


# From https://serverfault.com/questions/170346/how-to-edit-command-completion-for-ssh-on-zsh

h=()
if [[ -r ~/.ssh/config ]]; then
  h=($h ${${${(@M)${(f)"$(cat ~/.ssh/config)"}:#Host *}#Host }:#*[*?]*})
fi
if [[ -r ~/.ssh/known_hosts ]]; then
  h=($h ${${${(f)"$(cat ~/.ssh/known_hosts{,2} || true)"}%%\ *}%%,*}) 2>/dev/null
fi

if [[ $#h -gt 0 ]]; then
  zstyle ':completion:*:ssh:*' hosts $h
  zstyle ':completion:*:slogin:*' hosts $h
fi


# zstyle ':completion:*:ssh:*' hosts


alias vim=nvim

export EDITOR=nvim

if [[ -f ~/.zshrc && -f ~/.zshrc.extra ]]; then
  source ~/.zshrc.extra
fi


