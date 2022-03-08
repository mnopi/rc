# shellcheck shell=bash

#######################################
# Parallel ENV
# https://www.gnu.org/software/parallel/env_parallel.html
#######################################
! cmd env_parallel.bash || cmd env_parset || . env_parallel.bash

if [ "${PS1-}" ]; then
  #######################################
  # Exec Fail
  # a non-interactive shell will not exit if it cannot execute the file specified as an argument
  # to the exec builtin command. An interactive shell does not exit if exec fails.
  #######################################
  shopt -s execfail

  ! cmd direnv || cmd _direnv_hook || { eval "$(direnv hook bash)" && alias allow='direnv allow'; }

  #######################################
  # Homebrew Command Not Found
  # https://github.com/Homebrew/homebrew-command-not-found
  # BASH is checked in $HB_CNF_HANDLER
  #######################################
  [ ! -f "${HB_CNF_HANDLER?}" ] || cmd command_not_found_handle || . "${HB_CNF_HANDLER}"
fi
