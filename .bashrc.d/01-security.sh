#!/bin/bash

##
## SSH Helpers
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
  elif [[ $RMHOST =~ (x[a-z]{3,10}|x[a-z]{5,}[0-9].*)\.xilinx\.com$ ]]; then
    echo "given a FQDN"
    RMHOSTFQDN=$RMHOST
    RMHOSTNAME=$(echo ${RMHOSTFQDN} | cut -d. -f1)
    RMHOSTIP=$(/bin/host ${RMHOSTIP} | awk '{print $4}')
  fi
  RMHOSTS=(${RMHOSTIP} ${RMHOSTNAME} ${RMHOSTFQDN})
  echo "all hosts are ${RMHOSTS[@]}"
  for entry in ${RMHOSTS[@]}; do
    ssh-keygen -f "${SSH_DIR}/known_hosts" -R "$entry";
  done
}


KEY_FILES=()
AVAILABLE_KEYS=()
LOCAL_FS_REGEX='ext2/ext3|ext4|zfs|btrfs'
LOCAL_SSH_DIR=

function find-local-ssh-dirs-keys() {
  for HOME_PREFIX in ${HOME_DIR_PREFIXES[@]}; do
    SSH_DIR=${HOME_PREFIX}/${USER}/.ssh
    if [[ -r "${HOME_PREFIX}/${USER}" && -d "${SSH_DIR}" ]]; then
      DIR_STAT=$(/bin/stat -f -c %T ${SSH_DIR})
      if [[ ! ${DIR_STAT} =~ ${LOCAL_FS_REGEX} ]]; then
        debugecho "${FUNCNAME}() : Directory ${SSH_DIR} not on local filesystem. Skipping."
        continue
      fi
      for KEY in $( grep 'BEGIN OPENSSH PRIVATE KEY' ${SSH_DIR}/* | cut -d: -f1 | sort -u ); do
        KEY_STAT=$(/bin/stat -f -c %T ${KEY})
        if [[ ${KEY_STAT} =~ ${LOCAL_FS_REGEX} ]]; then
          debugecho "${FUNCNAME}() : Adding $KEY to available keys."
          AVAILABLE_KEYS+=("${KEY}")
          export LOCAL_SSH_DIR=${SSH_DIR}
        else
          debugecho "${FUNCNAME}() : Skipping private key ${KEY} is not on local filesystem. (Consider ${KEY} compromised.)"
          echo "${BT}${RED_T}WARNING:${RESET} Key file ${BT}${KEY}${RESET} is compromised on network filesystem. "
        fi
      done
    fi
  done
}


function find-set-big-ssh-sock() {
  # Find all agent sockets for current user.
  # Set environment to use active and populated ssh-agent.
  #
  SOCKET_KEY_COUNT=()
  BIG_SOCKS="null:0"
  for AGENT in $( find /tmp -type s -path "*/ssh*/agent*" -uid $(id -u) 2> /dev/null ); do
    debugecho "# Testing agent Socket for keys: $AGENT "
    AGENT_KEYS=()
    if SSH_AUTH_SOCK=$AGENT /bin/ssh-add -l 2> /dev/null > /dev/null ; then
      for KEY in $( SSH_AUTH_SOCK=$AGENT /bin/ssh-add -l | grep 'SHA256:' | awk '{print $2}' ); do
        AGENT_KEYS+=( "${KEY}" )
      done
      debugecho "${AGENT} has ${#AGENT_KEYS[@]}"
      SOCKET_KEY_COUNT+=("${AGENT}:${#AGENT_KEYS[@]}")
      if [ "${#AGENT_KEYS[@]}" -gt "${BIG_SOCKS##*:}" ]; then
        BIG_SOCKS=${AGENT}:${#AGENT_KEYS[@]}
      fi
    fi
    unset AGENT_KEYS
  done
  # Remove largest socket from array...
  debugecho "Your socket with the most keys is ${BIG_SOCKS}"
  SOCKET_KEY_COUNT=( "${SOCKET_KEY_COUNT[@]/${BIG_SOCKS}/}" )
  # Use BASH Regular Expressions and the internal capture group feature
  # to access the regular expression group index, the parenthesis () is the group identifier.
  for S in ${SOCKET_KEY_COUNT[@]}; do
    if [[ $S =~ \.([0-9]+): ]]; then
      if [ "${BIG_SOCKS}" != "null:0" ]; then
        debugecho "Searching for pid ${BASH_REMATCH[1]}"
        ps -ef | grep ${BASH_REMATCH[1]} | grep -v grep
      fi
    fi
  done
  export SSH_AUTH_SOCK=${BIG_SOCKS%:*}
  echo "export SSH_AUTH_SOCK=${BIG_SOCKS%:*}" # > ${LOCAL_SSH_DIR}/agent.env
}



function addsshkeyifnone() {
  retcode=$1
  if [ "$retcode" -ne 0 ]; then
    echo "Adding keys..."
    for KEY_FILE in ${AVAILABLE_KEYS[@]}; do
      ssh-add -t 259200 ${KEY_FILE}
    done
  elif [ "$retcode" -eq 0 ]; then
    echo "already have key in agent."
  fi
}


function sshagenthelper() {
  if [ -z $RUNNING ] ; then
    export RUNNING=1
    if pgrep -u ${MEME} ssh-agent 2>&1 >/dev/null ; then
      echo "ssh-agent running. finding one with keys..."
      find-set-big-ssh-sock
      #source ${LOCAL_SSH_DIR}/agent.env
      /bin/ssh-add -l 2>&1 > /dev/null
      addsshkeyifnone $?
    else
      echo "ssh-agent not running."
      echo "    finding local ssh directories..."
      find-local-ssh-dirs-keys
      echo "    Local SSH directory is ${LOCAL_SSH_DIR}"
      echo "    SSH directory ${LOCAL_SSH_DIR} is located on $(df -h ${LOCAL_SSH_DIR} )"
      if [ -d ${LOCAL_SSH_DIR} ]; then
        echo "    Starting ssh-agent"
        source <(/bin/ssh-agent)
        /bin/ssh-add -l 2>&1 > /dev/null
        addsshkeyifnone $?
      else
        echo "No local ssh directory found. (contents of LOCAL_SSH_DIR is: ${LOCAL_SSH_DIR})"
      fi
    fi
  fi
  unset RUNNING
}

# Forward SSH Agent socket over tunnel to enable key access on target machine.
alias ssh='sshagenthelper && ssh '
alias scp='sshagenthelper && scp '
alias ssh-add='sshagenthelper && ssh-add '
alias ssh-agent='sshagenthelper'

#
## END SSH Helper section.
#


##
## TLS / x509 helpers
##
function tls_check_cert_expiration() {
  if [ ${#1} -lt 1 ]; then
    echo "This shell function runs openssl to get the certificate validation dates beginning and expiring, information provided a hostname:portnumber. e.g. xsjminio.xilinx.com"
  fi
  echo "QUIT" | openssl s_client -connect ${1}:443 -showcerts 2>/dev/null | openssl x509 -inform pem -noout -text | grep -A2 'Validity' | grep -v Validity
}

function tls_get_cert() {
  if [ ${#1} -lt 1 ]; then
    echo "This shell function runs openssl to get the certificate information provided a hostname:portnumber. e.g. xsjminio.xilinx.com"
  fi
  echo "QUIT" | openssl s_client -connect ${1}:443 -showcerts 2>/dev/null | openssl x509 -inform pem -noout -text
}



# Setup things for CoPilot for VS Code.
# Debian/Ubuntu
if [ -f /etc/ssl/certs/ca-certificates.crt ]; then
  export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt
# Red Hat/CentOS
elif [ -f /etc/ssl/certs/cacerts.pem ]; then
  export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/cacerts.pem
#else
#  echo "Warning: Could not find /etc/ssl/certs/ca-certificates.crt  or /etc/ssl/certs/cacerts.pem."
#  echo "Node.js and other tools may not work properly with TLS."
fi


# Specify the CA certificate for git to use.
# This is needed for git to work with self-signed certificates.
#if [ -f /etc/ssl/certs/ca-certificates.crt ]; then
#  export GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt
#fi


function vault_init() {
  VAULT_ADDR=${VAULT_HOST:-pevault.tld.com}
  if [ -z ${VAULT_TOKEN} ]; then
    echo "Enter vault token: for ${VAULT_ADDR}"
    read -s VAULT_TOKEN
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

