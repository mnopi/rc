# shellcheck shell=sh disable=SC3040,SC3054,SC2296,SC2034,SC3028,SC2046,SC2139

#
# System and users profile for bash, busybox, dash, ksh, sh and zsh (/etc/profile and /etc/zprofile).
#
# https://www.gnu.org/software/bash/manual/html_node/Bash-POSIX-Mode.html
# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
# https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
# https://man7.org/linux/man-pages/man1/sh.1p.html
# https://man7.org/linux/man-pages/man1/dash.1.html
# https://linux.die.net/man/1/ksh
# https://www.mkssoftware.com/docs/man1/sh.1.asp
# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18
# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02
# BASH:
# /bin/bash or bash does not look at $ENV
# /bin/sh uses $ENV
# sudo su (with SHELL /bin/sh) uses $ENV
# Ideally .bashrc, although if I log in and no vars depending on the user...


[ "${PROFILE_SOURCED-0}" -eq 0 ] || return 0

# profile has been sourced (only once, needed for rc prompt, hooks and $RC_PREFIX)
#
PROFILE_SOURCED=1


# RC profile File ($ENV) Physical Path
#
#
export ENV="${RC?Must be set with RC repository or sourced by /etc/profile or /etc/zprofile}/profile"

# RC Repository or Downloaded Physical Path
#
export RC

# RC Sources Directory Physical Path Inside $RC
#
export RC_SRC="${RC}/rc"

# Running shell (posix-<ash|busybox|dash|ksh|sh>, zsh, sh for bash sh, bash or bash4)
#
SH="${ZSH_ARGZERO:-${0##*/}}"

__bash () {
  ENV="${BASH_SOURCE[0]}"
  SH="${BASH##*/}"
  [ "${BASH_VERSINFO[0]}" -lt 4 ] || { SH="bash-4"; shopt -s inherit_errexit; }
  set -o errtrace
}

case "${SH}" in
  ash|bash|busybox|dash|ksh|sh)
    SH="posix-${SH}"
    [ ! "${BASH_SOURCE-}" ] || __bash
    [ ! "${KSH_VERSION-}" ] || ENV="${.sh.file}"
    ;;
  -zsh|zsh)
    [ "${ZSH_EVAL_CONTEXT}" = "file" ] || ENV="$0"  # login ZSH_EVAL_CONTEXT=file
    SH="zsh"
    ;;
  *)
    if [ "${BASH-}" ]; then
      __bash
    elif [ "${ZSH_EVAL_CONTEXT-}" ]; then
      SH="zsh"
    elif [ "${KSH_VERSION-}" ]; then
      SH="posix-ksh"
    else
      SH="$(command cat /proc/$$/comm 2>/dev/null \
        || command ps -o pid= -o comm= 2>/dev/null | command sed -n "s/^ \{0,\}$$ //p")"
      case "${SH}" in
        ash|*/ash|busybox|*/busybox|sh|*/sh|dash|*/dash)
          SH="$(command readlink "$(command -pv "${SH}")" 2>/dev/null)"
          SH="posix-${SH##*/}"
          ;;
      esac
    fi
    ;;
esac
unset -f __bash

. "${RC_SRC}/profile.sh"

[ "${PS1-}" ] || echo $- | command grep -q i || return 0

. "${RC_SRC}/rc.sh"
