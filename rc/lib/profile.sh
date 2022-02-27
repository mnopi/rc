# shellcheck shell=sh

#
# Appended to /etc/profile during installation of rc

# RC $PATH compat dir: sourced in order by $RC_PROFILE after $RC_PROFILE_D,
# they can have a variable already defined in $RC_PROFILE_D
#
export RC_PATHS_D="${RC}/paths.d"

# RC profile.d compat dir: no order or dependencies, sourced by $RC_PROFILE
#
export RC_PROFILE_D="${RC}/profile.d"

for i in "${RC_PROFILE_D}"/*; do
  . "${i}"
done

eval "$("${RC}/bin/pathsd")"
