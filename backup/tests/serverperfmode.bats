#!/usr/bin/env bats
# shellcheck disable=SC2016

setup_file() { . "${BATS_TEST_DIRNAME}/helpers/load_profile.bash"; }

@test "$(description::file boot-args)" {
  skip::if '[ "${MACOS}" -eq 0 ]'
  run serverperfmode
  assert_success
  run sudo nvram boot-args
  assert_success
  assert_line --partial serverperfmode=1
}
