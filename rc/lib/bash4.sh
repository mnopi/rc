#!/bin/sh
# shellcheck disable=SC3054,SC2034

# BASH '1' if greater or equal than 4, '0' if BASH, unset if not BASH
#
unset BASH4

if [ "${BASH_VERSINFO-}" ]; then
  BASH4=0

  if [ "${BASH_VERSINFO[0]}" -ge 4 ]; then
    BASH4=1
  fi
fi
