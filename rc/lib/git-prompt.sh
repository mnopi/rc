#!/bin/sh
export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"



. "$(git --exec-path)/../../share/git-core/git-prompt.sh"
export PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
export PROMPT_COMMAND="__git_ps1 '\u@\h:\w' '\\$ '${PROMPT_COMMAND:+; ${PROMPT_COMMAND}}"
