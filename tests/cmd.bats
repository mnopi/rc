#!/usr/bin/env bats

setup_file() { . "${BATS_TEST_DIRNAME}/helpers/load_profile.bash"; }

@test "$(description::file type cmd script)" {
  run type cmd
  assert_output "cmd is $(command -v cmd)"
}

@test "$(description::file success)" {
  assert cmd ls
}

@test "$(description::file failure)" {
  run cmd foo
  assert_failure
}

@test "$(description::file success multiple)" {
  assert cmd ls cd sudo
}

@test "$(description::file failure multiple)" {
  run cmd ls foo sudo
  assert_failure
}

@test "$(description::file type cmd function)" {
  . cmd
  run type cmd
  assert_line "cmd is a function"
}

@test "$(description::file sourced)" {
  f() (:)

  run cmd f
  assert_failure

  . cmd
  run cmd f
  assert_success

  run cmd f sudo
  assert_success

  run cmd f foo sudo
  assert_failure
}
