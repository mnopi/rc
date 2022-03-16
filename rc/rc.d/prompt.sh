# shellcheck shell=sh

#######################################
# description
# Globals:
#   HOME
#   HOST_PROMPT
#   PROMPT_SH
#   function
#   rc
# Arguments:
#   1
#######################################
_prompt() {
  __rc=$?
  PS1='\[\e]0;\h@\u: \w\a\]'
  if [ "${__rc}" -eq 0 ]; then
    PS1="$(greenesc "✔ ")"
  else
    PS1="$(redesc "$1 ")"
  fi

  # TODO: /Library/Developer/CommandLineTools/usr/share/git-core
  #   substituir por ... o directamente quitarle el /
  PS1="${PS1}$(cyanesc "$(pwd | sed "s|${HOME}|~|" | tr '/' '\n' | tail -3 | \
    sed -n "H;\${x;s|\n|/|g;s|^//|/|;s|^/~|~|;s|^~/||;p;}") ")"

  [ ! "${HOST_PROMPT-}" ] || PS1="${PS1}$(blueesc "${HOST_PROMPT} ")"
  [ "${BASH4:-${SH}}" = "1" ] || PS1="${PS1}$(greyesc "${SH} ")"

  [ "$(id -u)" -eq 0 ] || function="greenesc"
  PS1="${PS1}$("${function:-magentaesc}" "〉")"
  : "${__rc}"
}

PS1="\$(_prompt \$?)"

ps1_selector="prompt"
case "${ps1_selector}" in
  prompt) export PROMPT_COMMAND="_prompt \$?${PROMPT_COMMAND:+; ${PROMPT_COMMAND}}" ;;
  starship)
    eval "$(starship init bash)"
#    PROMPT_COMMAND="${HISTAPPEND}${PROMPT_COMMAND:+; ${PROMPT_COMMAND}}"
    ;;
esac
export PS2="${YellowEsc}${VerboseIcon}${NormalEsc}"
#export PS2="\[\e[0;31m\]＞\[\e[0m\]"
#export PS2="\[\e[1;31m\]＞\[\e[0m\]"

