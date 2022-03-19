# shellcheck shell=sh

_prompt() {
  __rc=$?
#  PS2="${MagentaEsc}${VerboseIcon}${NormalEsc}"
  PS1="$(prompt $__rc "${SH}" "${SH_RC}")"
  PS2="$(prompt ps2 "${SH}")"
  return "${__rc}"
}
_title() { echo -ne "\033]0;\h@\u: \w\a\007"; }

case "${SH}" in
  zsh)
    setopt PROMPT_SUBST
    PROMPT='$(prompt $? "${SH}" "${SH_RC}")'
    PROMPT2='$(prompt ps2 "${SH}" )'
    ;;
esac
