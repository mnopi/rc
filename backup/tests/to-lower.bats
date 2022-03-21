#!/usr/bin/env bats

setup_file() { . "${BATS_TEST_DIRNAME}/helpers/load_profile.bash"; }

@test "$(description::file stdin)" {
  run sh -c 'echo FOO | to-lower'
  assert_success
  assert_output foo
}

@test "$(description::file arg)" {
  run to-lower FOO
  assert_success
  assert_output foo
}
