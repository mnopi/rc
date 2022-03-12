#!/bin/sh
# shellcheck disable=SC2034

# BASH '1' if greater or equal than 4, '0' if BASH, unset if not BASH
#
unset BASH4

# Has been sourced in BASH
#
SOURCED_BASH=0

# Has been sourced in DASH
#
SOURCED_DASH=0

# Has been sourced in KSH
#
SOURCED_KSH=0

# Has been sourced in SH
#
SOURCED_SH=0

# Has been sourced in ZSH
#
SOURCED_ZSH=0

# Default trap signal, EXIT for posix or ERR for BASH
#
TRAP_SIGNAL=EXIT

if [ "${BASH_VERSION-}" ]; then
  (return 0 2>/dev/null) && SOURCED_BASH=1
  BASH4=0
  TRAP_SIGNAL=ERR
  # shellcheck disable=SC3028,SC3054
  if [ "${BASH_VERSINFO[0]}" -ge 4 ]; then
    BASH4=1
  fi
elif [ -n "${ZSH_EVAL_CONTEXT}" ]; then
  case "${ZSH_EVAL_CONTEXT}" in *:file) SOURCED_ZSH=1 ;; esac
elif [ -n "${KSH_VERSION}" ]; then
  # shellcheck disable=SC2296
  [ "$(cd "$(dirname -- "$0")" && pwd -P)/$(basename -- "$0")" != "$(cd "$(dirname -- "${.sh.file}")" && \
    pwd -P)/$(basename -- "${.sh.file}")" ] && SOURCED_KSH=1
else
  case "${0##*/}" in 
    sh) SOURCED_SH=1 ;; 
    dash) SOURCED_DASH=1;; 
  esac
fi
