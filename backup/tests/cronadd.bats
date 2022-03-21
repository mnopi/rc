#!/usr/bin/env bats
# shellcheck disable=SC2016

setup_file() { . "${BATS_TEST_DIRNAME}/helpers/load_profile.bash"; teardown_file;}

teardown_file() { multidel; onedel; }

multidel() { cronadd rm @reboot rm -r /tmp/test &>/dev/null || true; }

onedel() { cronadd rm '5 0 * * *       $HOME/bin/daily.job >> $HOME/tmp/out 2>&1' &>/dev/null || true; }

@test "$(description::file add multi arguments)" {
  skip::if '! cmd crontab'

  multidel

  run cronadd @reboot rm -r /tmp/test
  assert_success
  assert_line --partial "Cron Added: @reboot rm -r /tmp/test"

  run crontab -l
  assert_success
  assert_line "@reboot rm -r /tmp/test"

  run cronadd rm @reboot rm -r /tmp/test
  assert_success
  assert_line --partial "Cron Deleted: @reboot rm -r /tmp/test"

  run sh -c "crontab -l | grep '@reboot rm -r /tmp/test'"
  assert_failure
}

@test "$(description::file add one argument)" {
  skip::if '! cmd crontab'

  onedel

  run cronadd '5 0 * * *       $HOME/bin/daily.job >> $HOME/tmp/out 2>&1'
  assert_success
  assert_line --partial 'Cron Added: 5 0 * * *       $HOME/bin/daily.job >> $HOME/tmp/out 2>&1'

  run crontab -l
  assert_success
  assert_line '5 0 * * *       $HOME/bin/daily.job >> $HOME/tmp/out 2>&1'

  run cronadd rm '5 0 * * *       $HOME/bin/daily.job >> $HOME/tmp/out 2>&1'
  assert_success
  assert_line --partial 'Cron Deleted: 5 0 * * *       $HOME/bin/daily.job >> $HOME/tmp/out 2>&1'

  run sh -c "crontab -l | grep '5 0 * * *       \$HOME/bin/daily.job >> \$HOME/tmp/out 2>&1'"
  assert_failure
}
