#!/bin/sh

#######################################
# description
# Globals:
#   PS1
#   _histappend
#   _rc
# Arguments:
#  None
# Returns:
#   $_rc ...
#######################################
PS1="${TERMINAL_TITLE}\$(prompt \$?)"
PROMPT_COMMAND="${HISTAPPEND}${PROMPT_COMMAND:+; ${PROMPT_COMMAND}}"
