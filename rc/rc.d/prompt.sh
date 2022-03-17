# shellcheck shell=sh
#
#_prompt() { PS1="$(prompt $?)"; }
#PS1="\$(prompt \$?)"  # dash, sh, busybox need a script.
#
#ps1_selector="prompt"
#case "${ps1_selector}" in
#  prompt) export PROMPT_COMMAND="_prompt \$?${PROMPT_COMMAND:+; ${PROMPT_COMMAND}}" ;;
#  starship) eval "$(starship init bash)" ;;
#esac
#export PS2="${YellowEsc}${VerboseIcon}${NormalEsc}"

