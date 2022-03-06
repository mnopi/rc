#!/usr/bin/env bats

setup_file() {
  . "${BATS_TEST_DIRNAME}/helpers/load_profile.bash"
  STDERR=0 STRICT=0 . helper.sh && export -f die error value
  export VARIABLE_NAME=1
  export NAME=VARIABLE
}

@test "$(description::file stdin)" {
  run sh -c "echo ${NAME}_NAME | value"
  assert_success
  assert_output 1
}

@test "$(description::file arg)" {
  run value "${NAME}_NAME"
  assert_success
  assert_output 1
}

@test "$(description::file failure)" {
  run value FOO
  assert_failure
  assert_output --regexp "Undefined Variable: ${FOO}"
}
