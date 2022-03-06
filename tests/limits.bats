#!/usr/bin/env bats

setup_file() { . "${BATS_TEST_DIRNAME}/helpers/load_profile.bash"; }

@test "$(description::file success)" {
  run limits
  assert_success

  if [ "${MACOS}" -eq 1 ]; then
    for command in maxfiles maxproc; do
      run sudo launchctl print "system/system.${command}"
      assert_success
    done
  fi
}
