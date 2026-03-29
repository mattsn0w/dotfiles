#!/bin/bash



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

