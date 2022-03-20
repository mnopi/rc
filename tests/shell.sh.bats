#!/usr/bin/env bats

setup() {
  . bats-libs.bash
  cd "${BATS_TEST_DIRNAME}"/.. || return
  export PATH="${PWD}/tests/fixtures:${PATH}"
}

container() {
  sh=( "${2-}" )
  docker run -it --rm -v "${PWD}:/${PWD##*/}" "${BATS_TEST_DESCRIPTION}" "$1" -c "/rc/tests/fixtures/shell ${sh[*]}"
}

debian() {
  run container "sh"
  assert_line --partial posix-dash

  run container "sh" "sh"
  assert_line --partial posix-dash

  run container "dash" "dash"
  assert_line --partial posix-dash

  run container "sh"
  assert_line --partial posix-dash

  run container "sh" "sh"
  assert_line --partial posix-dash

  run container "dash" "bash"
  assert_line --partial bash-4
}

equal() { assert_equal "$($1 -c ". ./lib/shell.sh; echo \$SH")" "${BATS_TEST_DESCRIPTION}"; }

@test "bash" {
  equal /bin/bash
}

@test "fixture: shell" {
  run shell
  assert_output bash-4

  run shell /bin/bash
  assert_output bash

  run shell dash
  assert_output posix-dash

  run shell ksh
  assert_output posix-ksh

  run shell sh
  assert_output sh

  run shell zsh
  assert_output zsh
}

@test "bash-4" { . ./lib/shell.sh; assert_equal "${SH}" "bash-4"; }

@test "posix-dash" { equal dash; }

@test "posix-ksh" { equal ksh; }

@test "sh" { equal sh; }

@test "zsh" { equal zsh; }

@test "alpine" {
  run container "sh"
  assert_line --partial posix-busybox

  run container "sh" "sh"
  assert_line --partial posix-busybox

  run container "ash" "ash"
  assert_line --partial posix-busybox

  run container "ash"
  assert_line --partial posix-busybox
}

@test "debian:bullseye" { debian; }

@test "debian:bullseye-backports" { debian; }

@test "debian:bullseye-slim" { debian; }

