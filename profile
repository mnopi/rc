# shellcheck shell=sh disable=SC3040,SC3054,SC2296,SC2034,SC3028,SC2046,SC2139

#
# System profile for bash, busybox, dash, ksh, sh and zsh.
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

[ "${RC_DEBUG-0}" -eq 0 ] || echo Sourced File: profile

# RC Installation Directory
#
export RC_INSTALL="/etc"

# RC Sources Directory Name
#
export RC_NAME="rc"

# RC Main Profile File Name
#
export RC_PROFILE="profile"

# RC Repository or Downloaded Physical Path
#
export RC_PREFIX

# ETC Directory or RC Repository Physical Path
# ETC="${RC_PREFIX:-${RC_INSTALL}}"
#
export ETC

# RC profile File ($ENV)Physical Path
#
#
export ENV="${RC_PREFIX:-${RC_INSTALL}}/${RC_PROFILE}"

# RC Sources Directory Physical Path
# RC="${ETC}/${RC_NAME}"
export RC

# Forces RC_PROMPT even if starship or zsh prompt are configured.
#
export RC_PROMPT="${RC_PROMPT:-0}"

# profile has been sourced (only at interactive shell and only once if called also from ~/.bashrc)
#
: "${PROFILE_SOURCED=0}"

# rc.d has been sourced (only at interactive shell and only once if called also from ~/.bashrc)
#
: "${RC_SOURCED=0}"

# Running shell (when is 'bash sh' will be set to 'bash')
#
: "${SH=""}"

# Hooks SH name for eval and init hooks (bash when sh is BASH), zsh for zsh, unset for posix (busybox, dash, ksh and sh)
: "${SH_HOOK=""}"

# rc.d filename based on shell to source if different to $SH: bash, bash4, posix (busybox, dash, ksh) and zsh.
#
: "${SH_RC=""}"

if [ "${PROFILE_SOURCED-0}" -eq 0 ]; then
  _profile_bash () {
    ENV="${BASH_SOURCE[0]}"
    SH="${BASH##*/}"
    SH_HOOK="bash"
    SH_RC="${SH}"
    [ "${BASH_VERSINFO[0]}" -lt 4 ] || { SH_RC="bash4"; shopt -s inherit_errexit; }
    set -o errtrace
  }

  PROFILE_SOURCED=1; _interactive_source=1
  SH="${ZSH_ARGZERO:-${0##*/}}"
  case "${SH}" in
    ash|bash|busybox|dash|ksh|sh)
      SH_RC="posix"
      [ ! "${BASH_SOURCE-}" ] || _profile_bash
      [ ! "${KSH_VERSION-}" ] || ENV="${.sh.file}"
      ;;
    -zsh|zsh)
      [ "${ZSH_EVAL_CONTEXT}" = "file" ] || ENV="$0"  # login ZSH_EVAL_CONTEXT=file
      SH="zsh"
      SH_HOOK="zsh"
      SH_RC="${SH}"
      ;;
    *)
      if [ "${BASH-}" ]; then
        _profile_bash
      elif [ "${ZSH_EVAL_CONTEXT-}" ]; then
        ENV="${ZSH_ARGZERO}"
        SH="zsh"
        SH_RC="${SH}"
      elif [ "${KSH_VERSION-}" ]; then
        ENV="${.sh.file}"
        SH="ksh"
        SH_RC="${SH}"
      else
        SH="$(command cat /proc/$$/comm 2>/dev/null \
          || command ps -o pid= -o comm= 2>/dev/null | command sed -n "s/^ \{0,\}$$ //p")"
        case "${SH}" in
         ash|*/ash|busybox|*/busybox|sh|*/sh|dash|*/dash) SH_HOOK=""; SH_RC="posix" ;;
         *) SH=""; SH_HOOK=""; SH_RC="" ;;
        esac
      fi
      ;;
  esac
  _shell="$(command readlink "$(command -pv "${SH}")" 2>/dev/null)"; _shell="${_shell##*/}"

  SH="${_shell:-${SH##*/}}"; unset _shell

  test -f "${ENV}" || { echo profile: "${ENV}": No such file, set \$RC_PREFIX to the directory of profile; return 1; }
  ETC="$( command -p cd "$( command -p dirname "${ENV}")" || return; command -p pwd -P )"
  ENV="${ETC}/${RC_PROFILE}"
  RC="${ETC}/${RC_NAME}"

  if [ "${RC_DEBUG-0}" -eq 1 ]; then
    for i in 0 ETC ENV RC SH SH_RC; do
      echo "${i}: $(eval echo \$$i)"
    done; unset i
  fi
fi

. "${RC}/profile.sh"

. "${RC}/rc.sh"

{ { [ "${PS1-}" ] || echo $- | command grep -q i; } && [ "${_interactive_source-0}" -eq 1 ]; } || return 0

alias bash4="/usr/bin/env bash --rcfile ${ENV}"
alias bash="/bin/bash --rcfile ${ENV}"
alias zsh='/bin/zsh --no-globalrcs'
alias alpine="cd ${RC_PREFIX} && container run alpine"
# RC_PREFIX=$PROJECT_DIR$;ZDOTDIR=$PROJECT_DIR$/.idea
# /bin/bash --rcfile /Users/j5pu/rc/profile
