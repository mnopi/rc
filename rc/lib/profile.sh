# shellcheck shell=sh disable=SC3040

#
# Appended to /etc/profile during installation of rc

umask 002

# profile.sh has been sourced (only at login shell and only once
#
export PROFILE_SOURCED="${PROFILE_SH_SOURCED:-0}"

# rc.d has been sourced
#
: "${RC_SOURCED=0}"

# Check to only run once
if [ "${PROFILE_SH_SOURCED-0}" -eq 0 ]; then
  PROFILE_SH_SOURCED=1

  # RC completions: sourced by $RC_PROFILE at the end
  #
  export RC_COMPLETIONS_D="${RC}/completions.d"

  # rc.d compat dir:  sourced $RC_PROFILE_SH after pathsd (libs and bin)
  #
  export RC_D="${RC}/rc.d"

  # RC $PATH compat dir: sourced in order by $RC_PROFILE after $RC_PROFILE_D,
  # they can have a variable already defined in $RC_PROFILE_D
  #
  export RC_PATHS_D="${RC}/paths.d"

  # RC profile.d compat dir: everything that is exported (only run once), sourced by $RC_PROFILE_SH
  #
  export RC_PROFILE_D="${RC}/profile.d"

  # RC share (not exported)
  #
  export RC_SHARE="${RC}/share"

  for _rc_profile in "${RC_PROFILE_D}"/*; do
    . "${_rc_profile}"
  done; unset _rc_profile

  eval "$("${RC}/bin/pathsd")"
fi

for _rc_d in "${RC_D}"/*.sh; do
  . "${_rc_d}"
done; unset _rc_d
