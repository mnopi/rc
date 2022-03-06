#!/usr/bin/env bats
# shellcheck disable=SC2016

setup_file() {
  . "${BATS_TEST_DIRNAME}/helpers/load_profile.bash"
  export REBOOT_NEEDED=1
  token-reboot needed || export REBOOT_NEEDED=0
  TOKEN_FILE="$(token-reboot file)"; export TOKEN_FILE
}

teardown() { clean; }

teardown_file() { clean; }

clean() { [ "${REBOOT_NEEDED}" -eq 1 ] || token-reboot rm; }

@test "$(description::file cron set)" {
  skip::if '! cmd crontab'

  run token-reboot touch
  assert_success
  assert_exist "${TOKEN_FILE}"

  run token-reboot cron
  assert_success

  run crontab -l
  assert_success
  assert_line "@reboot sudo rm -f ${TOKEN_FILE}"

  run token-reboot needed
  assert_success
}
