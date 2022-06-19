#!/usr/bin/env bats
# shellcheck disable=SC2001,SC2088,SC2016

setup_file() {
  . "${BATS_TEST_DIRNAME}/helpers/load_profile.bash"
  repo="$(mktemp -d)"; export repo
  git -C "${repo}" init
  mkdir "${repo}/dir"
}

teardown_file() {
  rm -rf "${repo}"
  pkill -f 'Docker' || true
}

@test "$(description::file container parsing '->' failure)" {
  commands="$(cat <<EOF
foo
all
alias
alias foo
image
image foo
run
run foo
sh
sh foo
EOF
)"
  skip::if '! cmd docker'

  run container
  assert_failure

  while read -r args; do
    # : fix to avoid passing commands stdin to "container all"
    : | run container "${args}"
    assert_failure
  done <<< "${commands}"
}

@test "$(description::file container commands)" {
  skip::if '! cmd docker'

  run container commands
  assert_line run
}

@test "$(description::file container 'alias|image' alpine)" {
  skip::if '! cmd docker'

  for i in alias image; do
    run container "${i}" alpine
    assert_success
    assert_output alpine
  done
}

@test "$(description::file container 'aliases|images')" {
  skip::if '! cmd docker'

  for i in aliases images; do
    run container "${i}"
    assert_success
    assert_line alpine
  done
}

@test "$(description::file 'ls | container run alpine <- ./entrypoint.sh')" {
  skip::if '! cmd docker'

  run sh -c 'echo "ls" | container run alpine'

  assert_success
  assert_line "${BATS_TOP_BASENAME}"
}

@test "$(description::file 'env | container run alpine <- ./entrypoint.sh')" {
  skip::if '! cmd docker'

  run sh -c 'echo "env" | container run alpine'

  assert_success
  assert_line ALPINE=1
  assert_line ALPINE_LIKE=1
  assert_line CONTAINER=1
  assert_line DIST_ID=alpine
  assert_line DIST_ID_LIKE=alpine
  assert_line --regexp DIST_VERSION=*
  assert_line --regexp HOST=*
  assert_line --regexp 'HOST_PROMPT=ꜿ *'
  assert_line MACOS=0
  assert_line PM=apk
  assert_line 'PM_INSTALL=sudo apk apk add -q --no-progress --no-cache'
  assert_line SUDOC=
  assert_line UNAME=Linux
  assert_line VGA=
}

@test "$(description::file 'ls foo | container run alpine -> failure <- ./entrypoint.sh')" {
  skip::if '! cmd docker'

  run sh -c 'printf "%s\n" ls foo | container run alpine'

  assert_failure
  assert_output --partial 'ls: foo: No such file or directory'
}

@test "$(description::file 'cd ~; ls | container run alpine <- no ./entrypoint.sh')" {
  skip::if '! cmd docker'

  cd ~

  run sh -c 'echo "ls" | container run alpine'

  assert_success
  assert_line "${PWD##*/}"
}

@test "$(description::file 'cd $repo/dir; ls | container run alpine <- no ./entrypoint.sh')" {
  skip::if '! cmd docker'

  cd "${repo}/dir"
  run sh -c 'echo "ls" | container run alpine'
  assert_success
  assert_line "${repo##*/}"
}

@test "$(description::file container run alpine ls -1 '<-' ./entrypoint.sh)" {
  skip::if '! cmd docker'

  run container run alpine ls -1

  assert_success
  assert_line --partial "${BATS_TOP_BASENAME}"  # is color tty (-t), directory in blue
  refute_line "${BATS_TOP_BASENAME}"  # is color tty (-t), directory in blue
}

@test "$(description::file container run alpine env '<-' ./entrypoint.sh)" {
  skip::if '! cmd docker'

  run container run alpine env

  assert_success
  assert_line --partial ALPINE=1
  assert_line --partial ALPINE_LIKE=1
  assert_line --partial CONTAINER=1
  assert_line --partial DIST_ID=alpine
  assert_line --partial DIST_ID_LIKE=alpine
  assert_line --regexp DIST_VERSION=*
  assert_line --regexp HOST=*
  assert_line --regexp 'HOST_PROMPT=ꜿ *'
  assert_line --partial MACOS=0
  assert_line --partial PM=apk
  assert_line --partial 'PM_INSTALL=sudo apk apk add -q --no-progress --no-cache'
  assert_line --partial SUDOC=
  assert_line --partial UNAME=Linux
  assert_line --partial VGA=
}

@test "$(description::file "container run alpine -c 'printf \"%s\" \"\${ALPINE}\"' '<-' ./entrypoint.sh")" {
  skip::if '! cmd docker'

  run container run alpine -c 'printf "%s" "${ALPINE}"'

  assert_success
  assert_line 1
}

@test "$(description::file container run alpine ls foo '<-' ./entrypoint.sh)" {
  skip::if '! cmd docker'

  run container run alpine ls foo

  assert_failure
  assert_line --partial 'ls: foo: No such file or directory'
}

@test "$(description::file 'cd ~/; container run alpine ls -1 <- no ./entrypoint.sh')" {
  skip::if '! cmd docker'

  cd ~

  run container run alpine ls -1

  assert_success
  assert_line --partial "${PWD##*/}"  # is color tty (-t), directory in blue
  refute_line "${PWD##*/}"  # is color tty (-t), directory in blue
}

@test "$(description::file 'cd ~/; container sh alpine -c ls -1 <- no ./entrypoint.sh')" {
  skip::if '! cmd docker'

  cd ~

  run container sh alpine -c ls -1

  assert_success
  assert_line --partial "${PWD##*/}"  # is color tty (-t), directory in blue
  refute_line "${PWD##*/}"  # is color tty (-t), directory in blue
}

@test "$(description::file 'cd $repo/dir; container run alpine ls -1 <- no ./entrypoint.sh')" {
  skip::if '! cmd docker'

  cd "${repo}/dir"

  run container run alpine ls -1

  assert_success
  assert_line --partial "${repo##*/}"  # is color tty (-t), directory in blue
  refute_line "${repo##*/}"  # is color tty (-t), directory in blue
}

@test "$(description::file 'cd $repo/dir; container sh alpine -c ls -1 <- no ./entrypoint.sh')" {
  skip::if '! cmd docker'

  cd "${repo}/dir"

  run container sh alpine -c ls -1

  assert_success
  assert_line --partial "${repo##*/}" # is color tty (-t), directory in blue
  refute_line "${repo##*/}"           # is color tty (-t), directory in blue
}

@test "$(description::file 'container run bash --help <- ./entrypoint.sh')" {
  skip::if '! cmd docker'

  # Note: --version or any -- can not be used with sh in busybox since it goes to shell (only --help)
  run container run bash --help

  assert_success
  assert_line --partial BusyBox
  refute_line --partial 'GNU bash'
}

@test "$(description::file 'cd $repo/dir; container sh bash --help <- no ./entrypoint.sh')" {
  skip::if '! cmd docker'

  cd "${repo}/dir"

  run container sh bash --help

  assert_success
  assert_line --partial 'BusyBox'
  refute_line --partial 'GNU bash'
}

@test "$(description::file 'cd $repo/dir; container run bash --version <- no ./entrypoint.sh')" {
  skip::if '! cmd docker'

  cd "${repo}/dir"

  run container run bash --version

  # Note: --version or any -- can not be used with sh in busybox since it goes to shell (only --help)
  # --version with alpine would hava hangout forever in shell
  assert_success
  assert_line --partial 'GNU bash'
  assert_line --partial 'License GPLv3+: '
}

@test "$(description::file container run fail ls '->' failure invalid manifest)" {
  skip::if '! cmd docker'

  run container run fail ls

  assert_failure
  assert_line --partial 'or Invalid Manifest '
}

@test "$(description::file container run bats/bats ls -1 '->' success manifest '<-' ./entrypoint.sh)" {
  skip::if '! cmd docker'

  run container run bats/bats ls -1

  assert_success
  assert_line --partial "${BATS_TOP_BASENAME}"  # is color tty (-t), directory in blue
  refute_line "${BATS_TOP_BASENAME}"  # is color tty (-t), directory in blue
}

@test "$(description::file container all uname -s)" {
  skip::if '! cmd docker'

  run container all uname -s

  assert_success
  assert_output < <(cat <<EOF
Linux
Linux
Linux
Linux
Linux
Linux
Linux
Linux
Linux
Linux
Linux
Linux
Linux
Linux
Linux
Linux
EOF
)
}

@test "$(description::file container all -c 'echo $DIST_ID')" {
  skip::if '! cmd docker'

  run container all -c 'echo $DIST_ID'

  assert_success
  assert_output < <(cat <<EOF
debian
arch
debian
fedora
debian
alpine
alpine
busybox
ubuntu
kali
kali
debian
debian
debian
centos
alpine
EOF
)
}
