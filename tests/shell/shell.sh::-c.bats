#!/usr/bin/env bats

setup() { load ../helpers/helper_setup; }

lib() { "$@" ". ./lib/shell.sh; echo \$SH"; }

@test "/bin/bash -c" {
  macos || skip
  run lib /bin/bash -c
  assert_output bash
}

@test "bash -c" {
  run lib bash -c
  assert_output bash-4
}

@test "bash-4" {
  . ./lib/shell.sh
  assert_equal "${SH}" "bash-4"
}

@test "posix-dash" {
  run lib dash -c
  assert_output posix-dash
}

@test "posix-ksh" {
  run lib ksh -c
  assert_output posix-ksh
}

@test "sh" {
  run lib sh -c
  if macos; then
    assert_output sh
  elif debian; then
    assert_output posix-dash
  else
    skip
  fi
}

@test "zsh" {
  run lib zsh -c
  assert_output zsh
}
