# shellcheck shell=sh disable=SC3037,SC2034,SC3030,SC3024,SC3054,SC3028

# TODO: terminar de probar y mirar lo del directorio y dejarlo de una puta vez!!!
#  y mirar las imágenes y el self de los huevos. Meter el .oh-,y-zsh aqui tambien con
# symlink del etc/profile al zprofile y y un git submodule...
_prompt() { __rc=$?; PS2="${MagentaEsc}${VerboseIcon}${NormalEsc}"; PS1="$(BASH4="${BASH4}" SH="${SH}" prompt $__rc)"; }
_title() { echo -ne "\033]0;\h@\u: \w\a\007";  }
PS1="\$(BASH4=\${BASH4} SH=\${SH} prompt \$?)"  # dash, sh, busybox need a script.
export PS2="${MagentaEsc}${VerboseIcon}${NormalEsc}"

case "${SH}" in
  bash|sh)
    [ "${BASH_VERSION}" ] || return
    [ "${BASH_VERSINFO[0]}" -lt 4 ] || BASH4=1
    _hook=bash;
    starship_precmd_user_func="_title"
    ;;
  busybox) return ;;
  dash|ksh)
    PS2="$(magenta "${VerboseIcon}\007")"
    return
    ;;
  zsh)
    _hook="${SH}"
    . "${RC_D}"/*"${SH}"
    ;;
esac

if cmd starship && [ -f "${STARSHIP_CONFIG-}" ]; then
  eval "$(starship init "${_hook}")"
else
  export PROMPT_COMMAND="BASH4=\${BASH4} SH=\${SH} _prompt \$?${PROMPT_COMMAND:+; ${PROMPT_COMMAND}}"
fi

! cmd "env_parallel.${_hook}" || . "env_parallel.${_hook}"
! cmd direnv || { eval "$(direnv hook "${_hook}")" && alias allow='direnv allow'; }
[ ! -f "${HB_CNF_HANDLER?}" ] || . "${HB_CNF_HANDLER}"
