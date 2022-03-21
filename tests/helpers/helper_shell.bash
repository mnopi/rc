# shellcheck shell=bash

cd "$(dirname "${BASH_SOURCE[0]}")"/../.. || return
load tests/helpers/helper_setup.bash

#######################################
# run the container
# Globals:
#   DESCRIPTION
#   PWD
# Arguments:
#  None
#######################################
container() {
  local c=() script=("/rc/tests/fixtures/${DESCRIPTION[3]}.sh") shell=( "${DESCRIPTION[4]-}" )
  if [ "${DESCRIPTION[3]}" = '-c' ]; then
    c=( "${DESCRIPTION[3]}" )
    script=( "/rc/tests/fixtures/${DESCRIPTION[4]}.sh${DESCRIPTION[5]:+ ${DESCRIPTION[5]}}" )
    shell=()
  fi
  docker run -i --rm -v "${PWD}:/${PWD##*/}" \
    "${DESCRIPTION[0]}" "${DESCRIPTION[2]}" "${c[@]}" "${script[@]}" "${shell[@]}"

}

#######################################
# evaluates the output
# Globals:
#   BATS_TEST_DESCRIPTION
#   DESCRIPTION
# Arguments:
#  None
#######################################
shell() {
  ! runner || skip

  read -r -a DESCRIPTION <<< "${BATS_TEST_DESCRIPTION}"
  run container "$@"
  assert_line --partial "${DESCRIPTION[1]}"
}
