#!/usr/bin/env bats

setup_file() { . "${BATS_TEST_DIRNAME}/helpers/load_profile.bash"; }

# TODO:

@test "$(description::file \$SUDOC)" {
  ! test -x /usr/bin/sudo || assert_file_exist "${SUDOC}"
}
