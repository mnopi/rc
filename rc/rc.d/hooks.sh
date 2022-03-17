# shellcheck shell=sh disable=SC3037,SC2034,SC3030,SC3024

_prompt() { PS1="$(prompt $?)"; }
_title() { echo -ne "\033]0;\h@\u: \w\a\007";  }
PS1="\$(prompt \$?)"  # dash, sh, busybox need a script.

case "${SH}" in
  dash)
    export PS2="${Yellow}${VerboseIcon}${Normal}"
    return
    ;;
  zsh)
    _hook="${SH}"
    precmd_functions+=(_title)
    ;;
  *)
    [ "${BASH_VERSION}" ] || return
    _hook=bash;
    starship_precmd_user_func="_title"
esac

! cmd "env_parallel.${_hook}" || . "env_parallel.${_hook}"
! cmd starship || [ ! -f "${STARSHIP_CONFIG-}" ]|| eval "$(starship init "${_hook}")"
! cmd direnv || { eval "$(direnv hook "${_hook}")" && alias allow='direnv allow'; }
[ ! -f "${HB_CNF_HANDLER?}" ] || . "${HB_CNF_HANDLER}"
