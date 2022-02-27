#!/usr/bin/env bats

setup_file() {
  . "${BATS_TEST_DIRNAME}/helpers/load_profile.bash"
}

@test "$(cyan 'cyan ')" {
  type cyan
}
