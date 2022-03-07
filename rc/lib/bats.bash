#!/bin/bash

: "${BASH_SOURCE:?Must Run in BASH}"

repo='bats.bash'
top="$(git super)"
bats_exe="${top}/${repo}/bin/${repo}"

: "${top:?Must be Run from a GIT Repository}"

if [ ! -f "${bats_exe}" ] || ! git -C "${top}" config -f .gitmodules "submodule.${repo}.path" &>/dev/null; then
  git -C "${top}" submodule add --branch main --quiet --name "${repo}" \
    "https://github.com/j5pu/${repo}.git" "${repo}"
  git -C "${top}" add .gitmodules
  git -C "${top}" commit --quiet -a -m "submodule: ${repo}"
  git -C "${top}" push --quiet
fi

if [ "${BATS_SUITE_TEST_NUMBER-}" = '1' ] || [ ! -f "${bats_exe}" ]; then
  git -C "${top}" submodule --quiet update --force --remote "${repo}" 2>/tmp/.submodule \
    || { cat /tmp/.submodule; rm /tmp/.submodule; exit 1; }
fi

case "${BASH_SOURCE[0]##*/}" in
  bats|bats.bash|"${0##*/}") cmd=( source ) ;;
  *) cmd=() ;;
esac

unset repo top

"${cmd[@]}" "${bats_exe}" "$@"
