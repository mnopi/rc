#!/bin/sh
# shellcheck disable=SC2034,SC3040

# Has been sourced (for the shell that has been used check $SH)
#
SOURCED=0

# Default trap signal, EXIT for posix or ERR for BASH
#
TRAP_SIGNAL="EXIT"

if [ "${BASH_VERSION-}" ]; then
  # Running shell for prompt (when is 'bash sh 'will be set to 'sh' and bash version 4 unset)
  #
  PROMPT_SH="bash"
  # Running shell (when is 'bash sh' will be set to 'bash')
  #
  SH="${PROMPT_SH}"; TRAP_SIGNAL="ERR"
  ! (return 0 2>/dev/null) || SOURCED=1
  case "${0##*/}" in
    sh) PROMPT_SH="sh"; TRAP_SIGNAL="EXIT" ;;
  esac
  # shellcheck disable=SC3028,SC3054
  if [ "${BASH_VERSINFO[0]}" -ge 4 ]; then
    # Bash version greater or equal than 4
    #
    BASH4=1; unset PROMPT_SH
    shopt -s inherit_errexit
  fi
  # https://www.gnu.org/software/bash/manual/html_node/Bash-POSIX-Mode.html
  #
  set -o posix
  set -o errtrace
  shopt -s checkwinsize
  shopt -s histappend
  #######################################
  # Exec Fail
  # a non-interactive shell will not exit if it cannot execute the file specified as an argument
  # to the exec builtin command. An interactive shell does not exit if exec fails.
  #######################################
  shopt -s execfail
elif [ -n "${ZSH_EVAL_CONTEXT}" ]; then
  PROMPT_SH="zsh"; SH="${PROMPT_SH}"
  case "${ZSH_EVAL_CONTEXT}" in *:file) SOURCED=1 ;; esac
elif [ -n "${KSH_VERSION}" ]; then
  PROMPT_SH="ksh"; SH="${PROMPT_SH}"
  # shellcheck disable=SC2296
  if [ "$(cd "$(dirname -- "$0")" && pwd -P)/$(basename -- "$0")" != "$(cd "$(dirname -- "${.sh.file}")" && \
    pwd -P)/$(basename -- "${.sh.file}")" ]; then
      SOURCED=1
  fi
else
  case "${0##*/}" in 
    dash|sh) PROMPT_SH="${0##*/}"; SH="${PROMPT_SH}"; SOURCED=1 ;;
  esac
fi
