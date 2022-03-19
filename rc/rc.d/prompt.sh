# shellcheck shell=sh

_prompt() { PS1="$(prompt $? "${SH}" "${SH_RC}")"; }
_title() { echo -ne "\033]0;\h@\u: \w\a\007"; }

case "${SH}" in
  zsh)
    PROMPT='$(prompt $? "${SH}" "${SH_RC}")'
    PROMPT2='$(prompt ps2 "${SH}" )'
    ;;
esac
