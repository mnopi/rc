# shellcheck shell=bash

export SAVED_PATH

#######################################
# change to top repository path
# Globals:
#   BASH_SOURCE
# Arguments:
#  None
# Returns:
#   <unknown> ...
#######################################
cdtop() {
  cd "${BASH_SOURCE[0]}"/../.. || return
}

#######################################
# loads bats libs
# Arguments:
#  None
#######################################
libs() {
  local lib
  lib="$(brew --prefix)/lib"
  for i in bats-assert bats-file bats-support; do
    source "${lib}/${i}/load.bash"
  done
}

#######################################
# sets tests PATH
# Globals:
#   PATH
#   PWD
# Arguments:
#  None
#######################################
setpath() {
  if [ "${SAVED_PATH-}" ]; then
    export PATH="${SAVED_PATH}"
  else
    export PATH="${PWD}/tests/fixtures:${PATH}"
    export SAVED_PATH="${PATH}"
  fi
}

libs
cdtop
setpath

unset -f libs
