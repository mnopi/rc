#!/usr/bin/env bats
# shellcheck disable=SC2001

setup_file() {
  . "${BATS_TEST_DIRNAME}/helpers/load_profile.bash"
  line="$(newline-to "$(printf '%s\n' 1 '2 2' '3 ')")"; export line
  paths="$(newline-to "
/bin
/usr/bin
" :)"; export paths
}

@test "$(description::file regex true)" {
  value='3 '
  [[ "${value}" =~ ${line} ]]
}

@test "$(description::file regex false last)" {
  value='3'
  ! [[ "${value}" =~ ${line} ]]
}

@test "$(description::file regex false)" {
  value='2 '
  ! [[ "${value}" =~ ${line} ]]
}

@test "$(description::file newline to colon)" {
  (
    PATH="${paths}"
    type rm
  )
}

@test "$(description::file no separator end)" {
  echo "${paths}" | grep -qv ':$'
}
