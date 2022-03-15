#!/bin/sh

PS1="$(prompt)"
eval "$(starship init bash)"
PROMPT_COMMAND="${HISTAPPEND}${PROMPT_COMMAND:+; ${PROMPT_COMMAND}}"
