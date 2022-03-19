# shellcheck shell=sh

#
# System interactive rc for bash, busybox, dash, ksh, sh and zsh (sources rc.d based on shell).
# Not exported variables unless needed and only sourced once per interactive session.

[ "${RC_SH_SOURCED-0}" -eq 0 ] || return
[ "${RC_DEBUG-0}" -eq 0 ] || echo Sourced File: "${RC?}/rc.sh"


for _rc_d in "${RC_D}"/*.sh; do
  . "${_rc_d}"
done; unset _rc_d

! test -f "${RC_D}/${RC_SH-}" || . "${RC_D}/${RC_SH}"


