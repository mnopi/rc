#!/usr/bin/env bats

setup_file() {
  . "${BATS_TEST_DIRNAME}/helpers/load_profile.bash"
}

@test "$(description::file stdin)" {
  run sh -c 'echo foo | to-upper'
  assert_success
  assert_output FOO
}

@test "$(description::file arg)" {
  run to-upper foo
  assert_success
  assert_output FOO
}
