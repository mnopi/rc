# shellcheck shell=sh disable=SC3040,SC3054,SC2296,SC2034,SC3028,SC2046

#
# System /etc/profile
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
#
: "${ETC="${RC_PREFIX:-${RC_INSTALL}}"}"; export ETC

# RC profile File ($ENV)Physical Path
#
: "${ENV="${ETC}/${RC_PROFILE}"}"; export ENV

# RC Sources Directory Physical Path
#
: "${RC="${ETC}/${RC_NAME}"}"; export RC

# profile has been sourced (only at login shell and only one if called from /etc/profile, ~/.profile, ~/.bashrc ...)
#
: "${PROFILE_SOURCED=0}"; export PROFILE_SOURCED

# 1 if Sourced From Script and Not the Shell, 0 if sourced by a shell (as far as we know)
#
: "${MAIN=1}"

# rc.d has been sourced (only at interactive shell and only once if called also from ~/.bashrc)
#
: "${RC_SOURCED=0}"

# Running shell (when is 'bash sh' will be set to 'bash')
#
export SH="${0##*/}"

# Has been sourced (for the shell that has been used check $SH)
#
: "${SOURCED=0}"

# Default trap signal, EXIT for posix or ERR for BASH
#
export TRAP_SIGNAL="EXIT"

if [ "${RC_SOURCED-0}" -eq 0 ]; then
  RC_SOURCED=1; _interactive_source=1

  case "${ZSH_ARGZERO:-${SH}}" in
    ash|bash|dash|ksh|sh)
      MAIN=0
      [ ! "${BASH_SOURCE-}" ] || ENV="${BASH_SOURCE[0]}"
      [ ! "${KSH_VERSION-}" ] || ENV="${.sh.file}"
      SOURCED=1
      ;;
    -zsh|zsh)
      MAIN=0
      ENV="$0"
      SH="zsh"
      SOURCED=1
      ;;
    *)
      case "${BASH##*/}" in
        bash|sh)
          echo MIERDA
          MAIN=1
          ENV="${BASH_SOURCE[0]}"
          SH="${BASH##*/}"
          ! (return 0 2>/dev/null) || SOURCED=1
          ;;
      esac
      case "${ZSH_ARGZERO-}" in
        *)
          MAIN=1
          ENV="${ZSH_ARGZERO}"
          SH="zsh"
      esac
      case "${ZSH_EVAL_CONTEXT-}" in *:file) ENV="$0"; SH="zsh"; SOURCED=1 ;; esac
      [ ! "${KSH_VERSION}" ] || { ENV="${.sh.file}"; SH="ksh"; [ "$0" = "${ENV}" ] || SOURCED=1;  }
      ;;
  esac

  ETC="$( command -p cd "$( command -p dirname "${ENV}")" || return; command -p pwd -P )"
  ENV="${ETC}/${RC_PROFILE}"
  RC="${ETC}/${RC_NAME}"

  if [ "${BASH-}" ]; then
    TRAP_SIGNAL="ERR"
    set -o errtrace
    if [ "${BASH_VERSINFO[0]}" -ge 4 ]; then
      BASH4=1
      shopt -s inherit_errexit
    fi
  fi

  for i in 0 ETC ENV RC SH MAIN SOURCED; do
    echo "${i}: $(eval echo \$$i)"
  done; unset i
fi

if [ "${PROFILE_SOURCED-0}" -eq 0 ]; then
  PROFILE_SOURCED=1

  # RC Bin Directory for $PATH
  #
  export RC_BIN="${RC}/bin"

  # RC Colors Installation Directory for $PATH
  #
  export RC_COLOR="${RC}/color"

  # RC completions sourced on each interactive sh
  #
  export RC_COMPLETIONS_D="${RC}/completions.d"

  # rc.d compat dir sourced on each interactive sh
  #
  export RC_D="${RC}/rc.d"

  # RC Lib to be sourced for $PATH
  #
  export RC_LIB="${RC}/lib"

  # RC $PATH compat dir sourced on each login shell after $RC_PROFILE_D
  #
  export RC_PATHS_D="${RC}/paths.d"

  # RC profile.d compat dir sourced on each login shell
  #
  export RC_PROFILE_D="${RC}/profile.d"

  # RC share
  #
  export RC_SHARE="${RC}/share"

  for _rc_profile in "${RC_PROFILE_D}"/*; do
    . "${_rc_profile}"
  done; unset _rc_profile

  eval "$("${RC}/bin/pathsd")"
fi

{ [ "${PS1-}" ] && [ "${_interactive_source-0}" -eq 1 ]; } || return 0

[ ! "${BASH-}" ] || shopt -s checkwinsize execfail histappend

for _rc_d in "${RC_D}"/*.sh; do
  . "${_rc_d}"
done; unset _rc_d

# TODO: Y esto jode el dash por estar exportada las de direnv.
#    Y encima el PS1 sale mal en dash. y aun no he conseguido el PS2
#     ... igual los escapes no le gustan pero sale vacio, mirar en alpine
#     en color guardar los symbolos solos para el ps2 y lo hado a mano
#  mejor poner lo colores en una libreria y que hago el source el . helper.sh
#  y en el profile hacer un (. .source;
#   A="$(. ./color.sh; echo "${BlackEsc}")" y quitar los scripts de scaped!
#  mirar como poner las variables del profile para que salgan en bashpro
#[ ! "${BASH_VERSION-}" ] || declare -fx $(compgen -A function)  # to have them in sudo if I do not add .bashrc

# zsh -i -c '. ./profile'
# bash -c '. ./profile'
# dash -c '. ./profile'
# ksh -c '. ./profile'
# sh -c '. ./profile'
# docker run -it --rm -e RC_PREFIX=/rc -v "$PWD:/rc" alpine sh -c '. /rc/profile'

alias bash4="/usr/bin/env bash --rcfile \${ENV}"
alias bash="/bin/bash --rcfile \${ENV}"
