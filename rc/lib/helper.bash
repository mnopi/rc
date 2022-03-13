#!/usr/bin/env bash

[ "${BASH_VERSION-}" ] || return

# caller stack, except 0 for stack() function
#
export STACK

#######################################
# caller stack, except 0 for this function
# Globals:
#   STACK
# Arguments:
#   1     starting index (default: 1)
#######################################
# shellcheck disable=SC2120
stack() {
  declare -i i="${1:-1}"
  [ "${STACK-}" ] || export STACK=()
  local c
  while c="$(caller "$i")"; do
    STACK+=("${c}")
    ((i++))
  done
  declare -p STACK
  echo
}
