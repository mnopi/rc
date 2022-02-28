#!/usr/bin/env bats

setup_file() {
  . "${BATS_TEST_DIRNAME}/helpers/load_profile.bash"
}

@test "$(cyan 'PATH ')" {
#  unset PATH
#  eval "$(/usr/libexec/path_helper -s)"
  for i in CLT LINUXBREW JETBRAINS JETBRAINS_APPLICATIONS NODE_PREFIX PYTHON_PREFIX RC; do
    if [ -n "${!i}" ] && [ -d "${!i}" ]; then
      >&3 echo "${i}: ${!i}"
      [[ "${PATH}" =~ ${!i}  ]]
    fi
  done
}
