# shellcheck shell=sh disable=SC3045

. cmd.sh
. shell.sh

_prompt() { rc=$?; PS1="$(PROMPT_SH=${PROMPT_SH} prompt $rc)"; history -a; history -c; history -r; return $rc; }
PS1="\$(PROMPT_SH=\${PROMPT_SH} prompt \$?)"
export PROMPT_COMMAND="_prompt \$?${PROMPT_COMMAND:+; ${PROMPT_COMMAND}}"
[ ! "${BASH_VERSION}" ] || export -f _prompt
