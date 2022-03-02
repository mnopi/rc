#!/usr/bin/env bats
# shellcheck disable=SC2001,SC2088

setup_file() {
  . "${BATS_TEST_DIRNAME}/helpers/load_profile.bash"
}

@test "$(description::file container parsing '->' failure)" {
  commands="$(cat <<EOF
foo
image
image foo
name
name foo
run
run foo
EOF
)"
  run container
  assert_failure

  while read -r args; do
    run container "${args}"
    assert_failure
  done <<< "${commands}"
}

@test "$(description::file container commands)" {
  run container commands
  assert_line run
}

@test "$(description::file container 'image|name' alpine)" {
  for i in image name; do
    run container "${i}" alpine
    assert_success
    assert_output alpine
  done
}

@test "$(description::file container 'images|names')" {
  for i in images names; do
    run container "${i}"
    assert_success
    assert_line alpine
  done
}

@test "$(description::file container run alpine)" {
  run sh -c 'echo "ls;exit" | container run alpine'
  assert_success
  assert_line "${BATS_TOP_BASENAME}"
}

@test "$(description::file container run alpine '->' failure)" {
  run sh -c 'echo "ls foo;exit" | container run alpine'
  assert_failure
  assert_output 'ls: foo: No such file or directory'
}

@test "$(description::file container run alpine '<-' cd '~/')" {
  cd ~
  run sh -c 'echo "ls;exit" | container run alpine'
  assert_success
  assert_line "${USER}"
}
