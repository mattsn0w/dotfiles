#!/bin/bash

USER=$(whoami)
SSH_AGENT=$(which ssh-agent)
OS=$(uname)

echo "Whoami: $USER"
echo "SSH_AGENT binary: $SSH_AGENT"

if [[ "${OS}" =~ "Linux" ]]; then
  LOCAL_SCRATCH_SSH=/home/${USER}/.ssh
elif [[ "${OS}" =~ "Darwin" ]]; then
  LOCAL_SCRATCH_SSH=/Users/${USER}/.ssh
fi

if [ -d ${LOCAL_SCRATCH_SSH} ]; then
  echo "i: Local Home dir with .ssh exists:"
  ls -ld ${LOCAL_SCRATCH_SSH}
  echo
else
  echo "e: Local Scratch home does not exist."
  echo "e: Exiting"
  exit 1
fi

AGENT_ENV_FILE=${LOCAL_SCRATCH_SSH}/agent.env

if [ -f ${AGENT_ENV_FILE} ]; then
  echo "i: ssh agent.env exists at: ${AGENT_ENV_FILE}"
  echo
else
  echo "i: No ssh agent.env detected"
  echo
fi

AGENT_PID=$(ps -u ${USER} -ef | grep ${SSH_AGENT} | grep -v grep | awk '{print $2}')

if [ -f ${AGENT_ENV_FILE} ]; then
  echo "File ${AGENT_ENV_FILE} exists. Looking for running PID that matches..."
  AGENT_ENV_PID=$(grep 'SSH_AGENT_PID=' ${AGENT_ENV_FILE} | cut -d= -f2 | cut -d\; -f1)
  echo "AGENT_ENV_PID is ${AGENT_ENV_PID}"
  if [[ "${AGENT_ENV_PID}" =~ ^[0-9]+$ && "${AGENT_PID}" =~ ^[0-9]+$ ]]; then
    echo "i: AGENT_PID is a number: ${AGENT_PID}"
    echo "i: AGENT_ENV_PID is a number: ${AGENT_ENV_PID}"
  else
    echo "something is wrong, these are not integers"
    echo "i: AGENT_PID is a number: ${AGENT_PID}"
    echo "i: AGENT_ENV_PID is a number: ${AGENT_ENV_PID}"
    exit 1
  fi


  if [ "$AGENT_PID" -eq "$AGENT_ENV_PID" ]; then
    echo "Running Agent (${AGENT_PID}) matches agent.env pid. Sourcing it."
    source ${AGENT_ENV_FILE}
  fi
elif [ ! -f ${AGENT_ENV_FILE} ]; then
  echo "No existing agent file."
  if kill -0 "${AGENT_PID}" > /dev/null 2>&1; then
    echo "You have a running ssh-agent at pid ${AGENT_PID} but no matching agent.env"
  else
    echo "No running agent or agent.env. Starting and creating..."
    ${SSH_AGENT} > ${AGENT_ENV_FILE}
    source ${AGENT_ENV_FILE}
  fi
fi

