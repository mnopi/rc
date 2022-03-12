#!/bin/sh

#######################################
# prompt command
# Globals:
#   PS1
#   HISTAPPEND
#   _rc
# Arguments:
#  None
# Returns:
#   $_rc ...
#######################################
_prompt() {
  _rc=$?
  PS1="${TERMINAL_TITLE}$(prompt "$_rc")"
  eval "${HISTAPPEND}"
  return $_rc
}

export PROMPT_COMMAND="_prompt${PROMPT_COMMAND:+; ${PROMPT_COMMAND}}"
