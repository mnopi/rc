#!/bin/sh

#######################################
# command or commands exists
# Arguments:
#  command [command]    command or commands
# Returns:
#  1 if any of the command does not exist
#######################################
cmd() {
  : "${1?}"
  if [ $# -eq 1 ]; then
    type "$1" >/dev/null 2>&1
  else
    tmp="$(mktemp)"
    type "$@" >/dev/null 2>"${tmp}"
    ! test -s "${tmp}" || grep -qv "not found" "${tmp}"
  fi
}

case "${0##*/}" in
  cmd|cmd.sh) set -eu; cmd "$@" ;;
esac

