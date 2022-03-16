# shellcheck shell=bash

case "${SH}" in
  bash|sh) _hook=bash ;;
  zsh) _hook="${SH}";;
  *) return ;;
esac

#######################################
# Parallel ENV
# https://www.gnu.org/software/parallel/env_parallel.html
#######################################
cmd env_parallel."${_hook}" || . env_parallel."${_hook}"


cmd direnv || { eval "$(direnv hook "${_hook}")" && alias allow='direnv allow'; }

#######################################
# Homebrew Command Not Found
# https://github.com/Homebrew/homebrew-command-not-found
# BASH is checked in $HB_CNF_HANDLER
#######################################
[ ! -f "${HB_CNF_HANDLER?}" ] || cmd command_not_found_handle || . "${HB_CNF_HANDLER}"
