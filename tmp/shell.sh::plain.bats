#!/usr/bin/env bats

setup() {
  load ../helpers/helper_setup
}

alpine() {
  ## ASH
  run container "ash"
  assert_line --partial posix-busybox

  run container "ash" "busybox"
  assert_output --partial "applet not found"

  run container "ash" "sh"
  assert_line --partial posix-busybox

  ## SH
  run container "sh"
  assert_line --partial posix-busybox

  run container "sh" "ash"
  assert_line --partial posix-busybox

  run container "sh" "sh"
  assert_line --partial posix-busybox

  ## BUSYBOX
  run container "busybox"
  assert_output --partial "applet not found"
}

container() {
  ! runner || skip
  sh=("$2")
  docker run -i --rm -v "${PWD}:/${PWD##*/}" "${BATS_TEST_DESCRIPTION}" \
    "$1" "/rc/tests/fixtures/plain.sh" "${sh[@]}"
}

debian() {
  ## BASH
  run container "bash"
  assert_line --partial bash-4

  run container "bash" "bash"
  assert_line --partial bash-4

  run container "bash" "dash"
  assert_line --partial posix-dash

  run container "bash" "sh"
  assert_line --partial posix-dash

  ## DASH
  run container "dash"
  assert_line --partial posix-dash

  run container "dash" "bash"
  assert_line --partial bash-4

  run container "dash" "dash"
  assert_line --partial posix-dash

  run container "dash" "dash"
  assert_line --partial posix-dash


  ## SH
  run container "sh"
  assert_line --partial posix-dash

  run container "sh" "bash"
  assert_line --partial bash-4

  run container "sh" "dash"
  assert_line --partial posix-dash

  run container "sh" "sh"
  assert_line --partial posix-dash
}

equal() { assert_equal "$($1 ". ./lib/shell.sh; echo \$SH")" "${BATS_TEST_DESCRIPTION}"; }

shbash() {
  ## BASH
  run container "bash"
  assert_line --partial bash-4

  run container "bash" "bash"
  assert_line --partial bash-4

  run container "bash" "sh"
  assert_line --partial sh

  ## SH
  run container "sh"
  assert_line --partial sh

  run container "sh" "bash"
  assert_line --partial bash-4

  run container "sh" "sh"
  assert_line --partial sh
}

@test "bash-4" { . ./lib/shell.sh; assert_equal "${SH}" "bash-4"; }

@test "plain.sh" {
  # BASH
  run plain.sh
  assert_output bash-4

  if macos; then
    # /BIN/BASH
    run plain.sh /bin/bash
    assert_output bash
  fi

  # DASH
  run plain.sh dash
  assert_output posix-dash

  # KSH
  run plain.sh ksh
  assert_output posix-ksh

  # SH
  run plain.sh sh
  assert_output sh

  # ZSH
  run plain.sh zsh
  assert_output zsh
}

@test "alpine" { alpine; }

@test "archlinux" { shbash; }

@test "bash:latest" {
  alpine

  run container "sh" "bash"
  assert_line --partial bash-4

  run container "bash" "sh"
  assert_line --partial posix-busybox

  run container "bash"
  assert_line --partial bash-4

  run container "bash" "ash"
  assert_line --partial posix-busybox
}

@test "busybox" {
  run container "ash"
  assert_line --partial posix-ash

  run container "ash" "ash"
  assert_line --partial posix-ash

  run container "ash" "busybox"
  assert_output --partial "applet not found"

  run container "ash" "sh"
  assert_line --partial posix-sh

  run container "sh"
  assert_line --partial posix-sh

  run container "sh" "ash"
  assert_line --partial posix-ash

  run container "sh" "busybox"
  assert_output --partial "applet not found"

  run container "sh" "sh"
  assert_line --partial posix-sh

  run container "busybox"
  assert_output --partial "applet not found"
}

@test "centos" { shbash; }

@test "debian:bullseye" { debian; }

@test "debian:bullseye-backports" { debian; }

@test "debian:bullseye-slim" { debian; }

@test "fedora" { shbash; }

@test "kalilinux/kali-rolling" { debian; }

@test "kalilinux/kali-bleeding-edge" { debian; }

@test "python:3.10-alpine" { alpine; }

@test "python:3.10-bullseye" { debian; }

@test "python:3.10-slim" { debian; }

@test "ubuntu" { debian; }

@test "zshusers/zsh" {
  debian

  run container "zsh"
  assert_line --partial zsh

  run container "zsh" "zsh"
  assert_line --partial zsh

  run container "sh" "zsh"
  assert_line --partial zsh
}
