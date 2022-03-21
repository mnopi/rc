#!/usr/bin/env bats

setup_file() { . "${BATS_TEST_DIRNAME}/helpers/load_profile.bash"; }

@test "$(description::file \$RC exists)" {
  assert_dir_exist "${RC}"
}

@test "$(description::file profile.sh sourced)" {
  assert_dir_exist "${RC_PROFILE_D}"
  assert cmd cyan
}
