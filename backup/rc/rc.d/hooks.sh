# shellcheck shell=sh disable=SC3037,SC2034,SC3030,SC3024,SC3054,SC3028

# TODO: terminar de probar y mirar lo del directorio y dejarlo de una puta vez!!!
#  y mirar las imágenes y el self de los huevos. Meter el .oh-,y-zsh aqui también con

#TODO: mirar que he borrado los colores por lo que usaba en stack !
#PS1="\$(prompt \$? '${SH}' ${SH_RC})"  # dash, sh, busybox need a script.
#PS2="$(prompt ps2 "${SH}")"

case "${SH}" in
  bash|sh)
    [ "${BASH_VERSION}" ] || return
    _hook=bash;
    starship_precmd_user_func="_title"
    ;;
  busybox) return ;;
  dash|ksh)
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
  export PROMPT_COMMAND="_prompt \$?${PROMPT_COMMAND:+; ${PROMPT_COMMAND}}"
fi

! cmd "env_parallel.${_hook}" || . "env_parallel.${_hook}"
! cmd direnv || { eval "$(direnv hook "${_hook}")" && alias allow='direnv allow'; }
[ ! -f "${HB_CNF_HANDLER?}" ] || . "${HB_CNF_HANDLER}"
