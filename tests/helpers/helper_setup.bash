# shellcheck shell=bash

export SAVED_PATH="${PATH}"

#######################################
# running on debian
# Arguments:
#  None
# Returns:
#   1 if not running on debian and 0 if running on debian
#######################################
debian() { test -f /etc/os-release || grep -q debian /etc/os-release; }

#######################################
# setup starting environment with RC, PATH, etc.
# Globals:
#   PATH
#   PWD
# Arguments:
#  None
#######################################
envrc() {
  cd "$(dirname "${BASH_SOURCE[0]}")"/../.. || return
  PATH="${SAVED_PATH}"
  source .envrc
  source lib/base-images.bash
  cd "${RC}" || return
  PATH="${RC}/tests/fixtures:${PATH}"
}

#######################################
# loads bats libs
# Arguments:
#  None
#######################################
libs() {
  local i lib
  lib="$(brew --prefix)/lib"
  for i in bats-assert bats-file bats-support; do
    source "${lib}/${i}/load.bash"
  done
}

#######################################
# running on macOS
# Arguments:
#  None
# Returns:
#   1 if not running on macOS and 0 if running on macOS
#######################################
macos() { [ "$(uname -s)" = "Darwin" ]; }

#######################################
# description
# Globals:
#   GITHUB_RUN_ID
# Arguments:
#  None
# Returns:
#   1 if not running on GitHub and 0 if running as an action
#######################################
runner() { [ "${GITHUB_RUN_ID-}" ]; }

envrc
libs

unset -f libs
