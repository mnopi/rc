# shellcheck shell=sh disable=SC2034

#
# System and users interactive rc for bash, busybox, dash, ksh, sh and zsh (sources rc.d based on shell).
# Not exported variables unless needed and only sourced once per interactive session.

[ "${RC_SH_SOURCED-0}" -eq 0 ] || return 0

# rc.sh has been sourced (only at interactive shell and only once if called also from ~/.bashrc, ~/.zshrc)
#
RC_SH_SOURCED=1

case "${SH}" in
  posix-*) : ;;
  bash|bash-4|sh) __rc_hook="bash" ;;
  zsh) __rc_hook="${SH}" ;;
  *) : ;;
esac

for __rc_d in "${RC_D}"/*.sh; do
  . "${__rc_d}"
done; unset __rc_d

! test -f "${RC_D}/hooks/${__rc_hook-}" || . "${RC_D}/hooks/${__rc_hook}"


