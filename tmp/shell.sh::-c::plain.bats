#!/usr/bin/env bats

setup() {
  load ../helpers/helper_shell
}

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

@test "plain.sh bash" {
  macos || skip
  run plain.sh /bin/bash
  assert_output bash
}

@test "plain.sh bash-4" {
  run plain.sh
  assert_output bash-4
}

@test "plain.sh posix-dash" {
  run plain.sh dash
  assert_output posix-dash
}

@test "plain.sh posix-ksh" {
  run plain.sh ksh
  assert_output posix-ksh
}

@test "plain.sh sh" {
  run plain.sh sh
  assert_output sh
}

@test "plain.sh zsh" {
  run plain.sh zsh
  assert_output zsh
}

@test "plain.sh" {
  # BASH -c
  run plain.sh
  assert_output bash-4

  if macos; then
    # /BIN/BASH -c
    run plain.sh /bin/bash
    assert_output bash
  fi

  # DASH -c
  run plain.sh dash
  assert_output posix-dash

  # KSH -c
  run plain.sh ksh
  assert_output posix-ksh

  # SH -c
  run plain.sh sh
  assert_output sh

  # ZSH -c
  run plain.sh zsh
  assert_output zsh
}

@test "plain.sh" {
  # BASH -c
  run plain.sh
  assert_output bash-4

  if macos; then
    # /BIN/BASH -c
    run plain.sh /bin/bash
    assert_output bash
  fi

  # DASH -c
  run plain.sh dash
  assert_output posix-dash

  # KSH -c
  run plain.sh ksh
  assert_output posix-ksh

  # SH -c
  run plain.sh sh
  assert_output sh

  # ZSH -c
  run plain.sh zsh
  assert_output zsh
}

@test "plain.sh" {
  # BASH -c
  run plain.sh
  assert_output bash-4

  if macos; then
    # /BIN/BASH -c
    run plain.sh /bin/bash
    assert_output bash
  fi

  # DASH -c
  run plain.sh dash
  assert_output posix-dash

  # KSH -c
  run plain.sh ksh
  assert_output posix-ksh

  # SH -c
  run plain.sh sh
  assert_output sh

  # ZSH -c
  run plain.sh zsh
  assert_output zsh
}

@test "plain.sh" {
  # BASH -c
  run plain.sh
  assert_output bash-4

  if macos; then
    # /BIN/BASH -c
    run plain.sh /bin/bash
    assert_output bash
  fi

  # DASH -c
  run plain.sh dash
  assert_output posix-dash

  # KSH -c
  run plain.sh ksh
  assert_output posix-ksh

  # SH -c
  run plain.sh sh
  assert_output sh

  # ZSH -c
  run plain.sh zsh
  assert_output zsh
}


@test "alpine posix-busybox ash -c" { shell; }
