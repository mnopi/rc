#!/usr/bin/env bats

setup_file() {
  . "${BATS_TEST_DIRNAME}/helpers/load_profile.bash"
}

@test "$(cyan 'PATH ')" {
  for i in CLT LINUXBREW JETBRAINS JEBRAINS_APPLICATIONS NODE_PREFIX PYTHON_PREFIX RC; do
    [ -z "${!i}" ] || [ -d "${!i}" ] || [[ "${!i}" =~ ${PATH} ]]
  done
  type cyan
}
