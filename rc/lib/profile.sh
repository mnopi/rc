# shellcheck shell=sh

#
# Appended to /etc/profile during installation of rc

umask 002

# RC completions: sourced by $RC_PROFILE at the end
#
export RC_COMPLETIONS_D="${RC}/completions.d"

# rc.d compat dir: sourced in order ??-*.sh by $RC_PROFILE after $RC_PROFILE_D,
# install here if depend on $RC_PROFILE_D
#
export RC_D="${RC}/rc.d"

# RC $PATH compat dir: sourced in order by $RC_PROFILE after $RC_PROFILE_D,
# they can have a variable already defined in $RC_PROFILE_D
#
export RC_PATHS_D="${RC}/paths.d"

# RC profile.d compat dir: no order or dependencies, sourced by $RC_PROFILE
#
export RC_PROFILE_D="${RC}/profile.d"

# RC share
#
export RC_SHARE="${RC}/share"

for i in "${RC_PROFILE_D}"/*; do
  . "${i}"
done

eval "$("${RC}/bin/pathsd")"
