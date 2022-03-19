# shellcheck shell=sh

#
# System and users profile for bash, busybox, dash, ksh, sh and zsh (sources profile.d posix compliance).
# Exported variables and only sourced once per login session.

[ "${PROFILE_SH_SOURCED-0}" -eq 0 ] || return 0

# profile.sh has been sourced (only at login shell and only one if called from /etc/profile, ~/.profile, ~/.bashrc ...)
#
export PROFILE_SH_SOURCED=1

# RC Bin Directory for $PATH
#
export RC_BIN="${RC_SRC?}/bin"

# RC Colors Installation Directory for $PATH
#
export RC_COLOR="${RC_SRC}/color"

# Configuration for Tools that can be set with Global Variable and are not dynamically updated.
#
export RC_CONFIG="${RC_SRC}/config"

# RC completions sourced on each interactive sh
#
export RC_COMPLETIONS_D="${RC_SRC}/completions.d"

# rc.d compat dir sourced on each interactive sh
#
export RC_D="${RC_SRC}/rc.d"

# RC Lib to be sourced for $PATH
#
export RC_LIB="${RC_SRC}/lib"

# RC $PATH compat dir sourced on each login shell after $RC_PROFILE_D
#
export RC_PATHS_D="${RC_SRC}/paths.d"

# RC profile.d compat dir sourced on each login shell
#
export RC_PROFILE_D="${RC_SRC}/profile.d"

# RC share
#
export RC_SHARE="${RC_SRC}/share"

for __profile_d in "${RC_PROFILE_D}"/*.sh; do
  . "${__profile_d}"
done; unset __profile_d

eval "$("${RC_BIN}/pathsd")"
