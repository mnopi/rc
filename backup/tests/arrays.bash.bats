#!/usr/bin/env bats
# shellcheck disable=SC2153,SC2034

setup_file() { . "${BATS_TEST_DIRNAME}/helpers/load_profile.bash"; }

setup() {
  . arrays.bash
  # Arrays exported in setup_file are not seen in functions
  declare -Ag ASSOCIATED=(["key1"]=foo ["key2"]=bar)
  declare -g ARRAY=(foo boo bar)
  declare -g VARIABLE=1
}

@test "$(description::file cparray undefined COMP_WORDS)" {
  run cparray
  assert_failure
  assert_output --partial "declare: COMP_WORDS: not found"
}

@test "$(description::file cparray undefined variable)" {
  run cparray fake
  assert_failure
  assert_output --partial "declare: fake: not found"
}

@test "$(description::file cparray undefined array)" {
  run cparray VARIABLE
  assert_failure
  assert_output --partial 'Undefined Array: declare -- VARIABLE="1"'
}

@test "$(description::file cparray ARRAY)" {
  cparray ARRAY
  for i in "${!ARRAY[@]}"; do
    assert_equal "${ARRAY[$i]}" "${_ARRAY[$i]}"
  done
}

@test "$(description::file cparray ARRAY '<-' modified)" {
  unset "ARRAY[1]"
  cparray ARRAY
  for i in "${!ARRAY[@]}"; do
    assert_equal "${ARRAY[$i]}" "${_ARRAY[$i]}"
  done
}

@test "$(description::file cparray ASSOCIATED)" {
  cparray ASSOCIATED
  for i in "${!ASSOCIATED[@]}"; do
    assert_equal "${ASSOCIATED[$i]}" "${ASSOCIATED[$i]}"
  done
}

@test "$(description::file getkey undefined variable)" {
  run getkey value fake
  assert_failure
  assert_output --partial "declare: fake: not found"
}

@test "$(description::file getkey undefined array)" {
  run getkey value VARIABLE
  assert_failure
  assert_output --partial 'Undefined Array: declare -- VARIABLE="1"'
}

@test "$(description::file inarray boo ARRAY '<-' modified)" {
  unset "ARRAY[1]"
  run inarray boo ARRAY
  assert_failure
}

@test "$(description::file inarray bar ARRAY '<-' modified)" {
  unset "ARRAY[1]"
  run inarray bar ARRAY
  assert_success
  assert_output ''
}

@test "$(description::file inarray foo ASSOCIATED)" {
  run inarray foo ASSOCIATED
  assert_success
  assert_output ''
}
