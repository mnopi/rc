# shellcheck shell=bash

# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
set -o errtrace  # Exit on error inside any functions or subshells.

if [ "${BASH4}" -eq 1 ]; then
  shopt -s inherit_errexit   # command substitution inherits the value of the errexit option
fi

if [ "${PS1-}" ]; then
  # a non-interactive shell will not exit if it cannot execute the file specified as an argument
  # to the exec builtin command. An interactive shell does not exit if exec fails.
  shopt -s execfail

  ! cmd direnv || cmd _direnv_hook || { eval "$(direnv hook bash)" && alias allow='direnv allow'; }

  # https://github.com/Homebrew/homebrew-command-not-found
  # BASH is checked in $HB_CNF_HANDLER
  [ ! -f "${HB_CNF_HANDLER?}" ] || cmd command_not_found_handle || . "${HB_CNF_HANDLER}"
fi
