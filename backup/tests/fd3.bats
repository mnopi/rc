#!/usr/bin/env bats

setup_file() { . "${BATS_TEST_DIRNAME}/helpers/load_profile.bash"; }

@test "$(description::file true)" { assert fd3; }
