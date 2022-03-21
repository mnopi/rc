#!/bin/sh
# shellcheck disable=SC3043,SC3030,SC3006,SC3024,SC3018,SC3010,SC3028,SC2153,SC2178,SC2128,SC3011

#
# helper shell library (sets bash strict mode by default).

# <html><h2>Show Debug Messages</h2>
# <p><strong><code>$DEBUG</code></strong> (Default: 0).</p>
# <p><strong><code>Debug messages are shown if set to 1.</code></strong></p>
# <p>Activate with either of:</p>
# <ul>
# <li><code>DEBUG=1</code></li>
# <li><code>--debug</code></li>
# </ul>
# </html>
: "${DEBUG=0}"

# <html><h2>Dry Run</h2>
# <p><strong><code>$DRY_RUN</code></strong> (Default: 0).</p>
# <p>Activate with either of:</p>
# <ul>
# <li><code>DRY_RUN=1</code></li>
# <li><code>--dryrun</code></li>
# </ul>
# </html>
: "${DRY_RUN=0}"

# Quiets any stderr/$XTRACE/$XVERBOSE when 1 (default: 0)
#
: "${QQUIET=0}"

# <html><h2>Silent Output</h2>
# <p><strong><code>$QUIET</code></strong> (Default: 0).</p>
# <p><strong><code>The following messages are shown if set to 0:</code></strong></p>
# <ul>
# <li><code>error</code></li>
# <li><code>success</code></li>
# </ul>
# <p><strong><code>If set to 0, other messages are shown base on the variable value:</code></strong></p>
# <ul>
# <li><code>debug</code>: $DEBUG</li>
# <li><code>verbose</code>: $VERBOSE</li>
# <li><code>warning</code>: $WARNING</li>
# </ul>
# <p>Activate with either of:</p>
# <ul>
# <li><code>QUIET=1</code></li>
# <li><code>--quiet</code></li>
# </ul>
# <p><strong><code>Note:</code></strong></p>
# <p>Takes precedence over $DEBUG, $VERBOSE and $WARNING.</p>
# </html>
: "${QUIET=0}"

# Shell Set Saved Starting State for _strict trap (can be reset with setsave())
#
: "${SETSAVE="$(mktemp)"}"; ! test -s "${SETSAVE}" || set | sort > "${SETSAVE}"

# <html><h2>Bash Strict Mode</h2>
# <p><strong><code>$STRICT</code></strong> set to 0 when sourcing helper.sh to not set strict mode (Default: 1).</p>
# <h3>Examples</h3>
# <dl>
# <dt>No strict mode:</dt>
# <dd>
# <pre><code class="language-bash">STRICT=0 . helper.sh
# </code></pre>
# </dd>
# </dl>
# <h3>Links</h3>
# <ul>
# <li><a href="http://redsymbol.net/articles/unofficial-bash-strict-mode/">Unofficial Bash Strict Mode</a></li>
# </ul>
# </html>
: "${STRICT=1}"

# <html><h2>Show Verbose Messages</h2>
# <p><strong><code>$VERBOSE</code></strong>  (Default: 0).</p>
# <p><strong><code>Verbose messages are shown if set to 1.</code></strong></p>
# <p>Activate with either of:</p>
# <ul>
# <li><code>VERBOSE=1</code></li>
# <li><code>--verbose</code></li>
# </ul>
# </html>
: "${VERBOSE=0}"

# Sets shell xtrace 'set -x' when 1 (default: 0)
#
: "${XTRACE=0}"

# Sets shell verbose 'set -x' when 1 (default: 0)
#
: "${XVERBOSE=0}"

# caller stack, except 0 for stack() function when running in BASH or file from psargs
#
export STACK

#######################################
# show variable values if DEBUG is set to 1, unless QUIET is set to 1
# Globals:
#   DEBUG
#   QUIET
# Arguments:
#   vars            Variable names.
# Output:
#   Message to stderr.
#######################################
debug() {
  content=; suffix=
  for arg do
    content="${content-}${suffix-}${arg}=$(eval echo "\$${arg}")"
    suffix=", "
  done
  >&2 stack "${Debug}" "${content}"
}

#######################################
# show message (success or error) with symbol (✓, x respectively) based on status code, unless QUIET is set and exit
# Globals:
#   QUIET              Do not show message if set (but 0), takes precedence over VERBOSE/DRY_RUN (default: unset).
# Arguments:
#   message            Message to show.
#   --desc             Show description and exit.
#   --help             Show help from man page and exit.
#   --manrepo          Show repository from man page and exit.
#   --version          Show version from man page and exit.
# Optional Arguments:
#   --debug            Show debug messages.
#   --dryrun           Show commands that will be executed.
#   --no-quiet         Do not silent output for commands which silent error by default (git top, etc.).
#   --quiet            Silent output.
#   --verbose          Show verbose messages.
#   --warning          Show warning messages.
# Note:
#  Do not use command substitution in the message when false || die.
#  Previous error code is overwritten by the command substitution return code.
#  $ cd "$(dirname "${input}")" 2>/dev/null || die Directory not Found: "$(dirname "${input}")"
# Output:
#   Message to stderr.
# Returns:
#   1-255 for error, 0 for success.
#######################################
die() {
  rc=$?
  [ "${QUIET-0}" -eq 0 ] || exit $rc
  case "${rc}" in
    0) Ok "$@" ;;
    *) stack "${Error}" "$@" ;;
  esac
  exit "${rc}"
}

#######################################
# check if a command exists.
# Arguments:
#   --all               Find all paths.
#   --path              Use path (does not have any effect for: '--all' and '--bin', always searches in $PATH).
#   --value             Show value (does not have any effect for: '--all' and '--bin', always shows value).
#   executable          Executable to check (default: sudo if no image and not executable).
#   image               The image name (default: local).
# Common Arguments:
#   --man               Show help from man page and exit.
#   --desc              Show description and exit.
#   --manrepo           Show repository from man page and exit.
#   --vers              Show version from man page and exit.
# Optional Arguments:
#   --debug             Show debug messages.
#   --dryrun            Show commands that will be executed.
#   --no-quiet          Do not silent output for commands which silent error by default (git top, etc.).
#   --quiet             Silent output.
#   --verbose           Show verbose messages.
#   --warning           Show warning messages.
# Returns:
#   1 if it does not exist.
#######################################
has() {
  fromman has "$@" || exit 0

  doc() { docker run -i --rm --entrypoint sh "${image}" -c "${1}"; }
  unset executable
  all=false; path=false; value=false
  unset image
  for arg; do
    case "${arg}" in
      -a|--all) all=true; value=true ;;
      -p|--path) path=true ;;
      -v|--value) value=true ;;
      -pv|-vp) path=true; value=true ;;
      -*) false || die Invalid Option: "${arg}";;
      *)
        if [ "${executable-}" ]; then
          image="${arg}"
        elif [ "${arg:-}" != '' ]; then
          executable="${arg}"
        fi
        ;;
    esac
  done

  executable="${executable:-sudo}"

  if [ "${image-}" ]; then
    docker --version >/dev/null || exit
    if $all; then
      rv="$(doc "which -a ${executable} || type -aP ${executable} || true")"
    elif $path; then
      rv="$(doc "{ which ${executable} || type -P ${executable}; } | head -1 || true")"
    else
      rv="$(doc "command -v ${executable} || true")"
    fi
  else
    if $all; then
      # shellcheck disable=SC3045
      rv="$(which -a "${executable}" || type -aP "${executable}" || true)"
    elif $path; then
      # shellcheck disable=SC3045
      rv="$({ which "${executable}" || type -P "${executable}"; } | head -1 || true)"
    else
      rv="$(command -v "${executable}" || true)"
    fi
  fi

  if [ "${rv-}" ] && $all; then
    tmp="$(mktemp)"
    for index in ${rv}; do
      r="$(real --resolved "${index}")"
      grep -q "^${r}$" "${tmp}" || echo "${r}" >> "${tmp}"
    done
    cat "${tmp}"
  elif [ "${rv-}" ]; then
    ! $value || echo "${rv}"
  else
    unset rv; unset -f doc
    return 1 2>/dev/null || exit 1
  fi
  unset all executable path rv value; unset -f doc
}

#######################################
# show error message with x symbol in red, unless QUIET is set to 1
#######################################
error() { stack "${Error}" "$@"; }

#######################################
# parse common long optional arguments.
# Output:
#   Message to stderr.
# Arguments:
#   [first]            Parse only the first argument.
#   --desc             Show description and exit.
#   --help             Show help from man page and exit.
#   --manrepo          Show repository from man page and exit.
#   --version          Show version from man page and exit.
# Optional Arguments:
#   --debug            Show debug messages.
#   --dryrun           Show commands that will be executed.
#   --no-quiet         Do not silent output for commands which silent error by default (git top, etc.).
#   --quiet            Silent output.
#   --verbose          Show verbose messages.
#   --warning          Show warning messages.
#   --white            Multi line error message.
# Returns:
#   1-255 for error, 0 for success.
#######################################
parse() {
  arg() {
    case "${1}" in
    --no-quiet) eval 'QUIET=0' ;;
    --debug|--dry-run|--qquiet|--quiet|--verbose|--warning|--white)
      eval "$(to-upper "${1#--}" | sed 's/-/_/')=1" ;;
    --*) fromman parse "$@" || exit 0 ;;
    esac
  }

  if [ "${1-}" = "first" ]; then
    shift
    arg "${1}"
  else
    for arg; do
      arg "${arg}"
    done
  fi
  unset -f arg
}

#######################################
# parent process args (cmd/command and args part of ps)
# if in a subshell or cmd of the current shell if running in a subshell.
# $$ is defined to return the process ID of the parent in a subshell; from the man page under "Special Parameters":
# expands to the process ID of the shell. In a () subshell, it expands to the process ID of the current shell,
# not the subshell.
# Arguments:
#   --desc             Show description and exit.
#   --help             Show help from man page and exit.
#   --manrepo          Show repository from man page and exit.
#   --version          Show version from man page and exit.
# Outputs:
#   Process (ps) args.
# Returns:
#   1 if error during installation of procps or not know to install ps or --usage and not man page.
# Posix: (args = command -> command and args, comm -> command) (-ww if arguments cut):
#     ps -o pid= -o args= | sed -n "s/^ \{0,\}$$ //p"  # all
#     ps -o pid= -o comm= | sed -n "s/^ \{0,\}$$ //p"  # command
#     ps -o pid= -o args= | sed -n "s/^ \{0,\}$PPID //p"
#     ps -o pid= -o comm= | sed -n "s/^ \{0,\}$PPID //p"
#     lsof -p $$ | tail -n1 | cut -d ' ' -f1
#######################################
psargs() {
  command sudo cat "/proc/${1-$$}/cmdline" 2>/dev/null | tr '\0' ' ' || \
    command sudo ps ax -o pid= -o args= 2>/dev/null | sed -n "s/^ \{0,\}${1-$$} //p";
}

pscomm() {
  sudo cat "/proc/${1-$$}/cmdline" 2>/dev/null | tr '\0' ' ' || \
    sudo ps ax -o pid= -o comm= 2>/dev/null | sed -n "s/^ \{0,\}${1-$$} //p";
}

#######################################
# updates variables in set save state file
# Globals:
#   SETSAVE
# Arguments:
#   None
#######################################
setsave() { set | sort > "${SETSAVE}"; }

#######################################
# caller stack, except 0 for this function or return first which does not have func or file.
# returns ps file if no BASH
# Globals:
#   STACK
# Arguments:
#   1       Symbol Value.
#   @       Arguments to print.
#######################################
stack() {
  [ ! "${1-}" ] || [ "${QUIET-0}" -eq 0 ] || return 0
  case "${1-}" in
    "${Debug}") [ "${DEBUG-0}" -eq 1 ] || return 0; symbol="$1"; color="${Magenta}"; shift ;;
    "${Error}") symbol="$1";  color="${Red}"; shift ;;
    "${Warning}") symbol="$1";  color="${Yellow}"; shift ;;
  esac
  #    symbol="$(printf '%b' "$1")"

  if [ "${BASH_VERSION-}" ]; then
    declare -i i=1
    local files="${BASH_SOURCE[0]##*/}" frame line func file
    [ "${STACK-}" ] || STACK=()

    while frame="$(caller "$i")"; do
      if [ "${symbol-}" ]; then
        file="$(basename "$(echo "${frame}" | cut -d ' ' -f3-)")"
        if [ "${file}" = "${BASH_SOURCE[0]##*/}" ] \
          && awk '{ print $2 }' <<<"${frame}" | grep -E "debug|die|error|verbose"; then
          continue
        else
          line="${Grey}[${Normal}${color}$(echo "${frame}" | awk '{ print $1 }')${Normal}${Grey}]${Normal}"
          break
        fi
      else
        STACK+=("${c}")
      fi
      ((i++))
    done
  else
    STACK="$(basename "$(psargs '' | awk '{ print $1 }')" 2>/dev/null || true)"
    file="${STACK}"
  fi
  [ "${symbol-}" ] || return 0
  [ ! "${file-}" ] || file=" $(printf "%b" "${color}${file}${Normal}${line-}")"
  printf "%b\n" "${symbol}${file} $(firstother "$@")"
}

#######################################
# trap set by 'stderr' function to show stderr on EXIT and format output based on stderr and/or 'set -x' for posix
# Globals:
#   EXIT_STDERR
#   QQUIET
#   SETOPTS
# Arguments:
#   None
#######################################
_stderr() {
  # set -u err not caught in signal EXIT.
  # if lsof is posix then use: stderr="$(lsof -d2 | grep $$ | awk '{ print $NF }')"
  rc=$?
  set +xv
  exec 2>&3
  #exec 2>&3 3>&-

  if test -s "${EXIT_STDERR-}"; then
    # Unset debug so grep unbound works and grep + 2 times just in case set -x and set +x was put in the middle.
    if grep -q -m2 '^\+\{0,\} ' "${EXIT_STDERR}"; then
      was_debug=1
    fi

    if [ $rc -eq 0 ] && grep -q ': unbound variable$|: parameter null or not set|: integer expression expected' \
      "${EXIT_STDERR}"; then
      rc=1
    fi

    if { [ "${was_debug-0}" -eq 1 ] || [ $rc -ne 0 ]; } && [ "${QQUIET-0}" -eq 0 ]; then
      >&2 echo
      # https://unix.stackexchange.com/questions/475548/removing-all-non-ascii-characters-from-a-workflow-file
      >&2 LC_ALL=C tr -dc '\0-\177' < "${EXIT_STDERR}" | sed "s/^\(+\)\1\{0,\} /$(magenta 'debug>  &')/g; \
        /^.*\[.*debug>/!s/^/$(red 'stderr>') /g"
    fi
  fi
  exit $rc
}

#######################################
# sets trap with '_stderr' function on EXIT and redirects stderr to FD 3
# Globals:
#   EXIT_STDERR
# Examples:
#   . helpers.sh && stderr
#   STDERR=1 . helpers.sh
# Caution:
#   New different shell can not be started when stderr is redirected (i.e.: from zsh starting bash)
#   New shells inherit 'test -t 2' (exec also maintains the redirect), therefore $EXIT_STDERR exported.
#######################################
stderr() {
  xtrace
  if test -t 2; then
    EXIT_STDERR="$(mktemp)"; export EXIT_STDERR
    exec 3>&2 2>"${EXIT_STDERR}"
    trap _stderr EXIT
  fi
}

#######################################
# Bash traceback for strict
# Globals:
#   BASH_COMMAND
#   BASH_LINENO
#   BASH_SOURCE
#   FUNCNAME
#   i
# Arguments:
#  None
#######################################
# shellcheck disable=SC3043,SC3028,SC3054,SC3005,SC3018,SC3037
_strict() {
  local code=$? funcname last
  set +x
  _tmp="$(mktemp)"
  set | grep -vE "^_=|^_tmp=" | sort > "${_tmp}"
  diff="$(mktemp)"
  comm -13 "${SETSAVE}" "${_tmp}" > "${diff}"

  last="$(magenta "${BASH_COMMAND}")"
  >&2 Error "${BASH_SOURCE[1]}:${BASH_LINENO[0]} ${last} ($(red $code))"
  if [ ${#FUNCNAME[@]} -gt 2 ]; then
    echo "  $(Debug)${BASH_SOURCE[1]} Traceback (most recent call first):"
    for ((i=0; i < ${#FUNCNAME[@]} - 1; i++)); do
      funcname="$(green "${FUNCNAME[$i]}")"
      [ "$i" -ne "0" ] || funcname="${last}"
      >&2 echo "    $(More)${BASH_SOURCE[$i + 1]}:${BASH_LINENO[$i]} ${funcname}"
    done
  fi

  >&2 printf "  $(Debug)$(italic "Vars File: ")%s\n" "${diff}"

  exit "${code}"
}

#######################################
# sets or unsets strict mode
# https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
# Globals:
#   BASH4
#   SHELLOPTS                   Bash sh options (exported for BASH so that new shells inherit '-x', etc.)
#                               exporting SHELLOPTS does not work with brew.
#   POSIXLY_CORRECT             Bash turns off set -e in subshells unless it's in POSIX mode (set -o posix or
#                               have POSIXLY_CORRECT in the environment when bash starts
# Arguments:
#   [unset]                     unsets strict mode
# Posix:
#   set -o errexit              Exit when simple command fails ('set -e').
#
#   set -o nounset              Trigger error when expanding unset variables ('set -u').
# Bash:
#   set -o errtrace             Any trap on ERR is inherited by shell functions, command substitutions,
#                               and commands executed in a subshell environment.
#                               The ERR trap is normally not inherited in such case ('set -E').
#   set -o pipefail             Exit on Error pipe error.
#   shopt -u inherit_errexit    Command substitution inherits the value of the errexit option.
#######################################
strict() {
  [ "${1-}" = 'unset' ] || { _set=-o; _opt=-s; }
  set "${_set:-+o}" errexit nounset
  if [ "${BASH_VERSION-}" ]; then
    if [ "${_set- }" ]; then
      # shellcheck disable=SC3047
      trap _strict ERR
    fi
    set "${_set:-+o}" errtrace
    set "${_set:-+o}" pipefail
    if [ "${BASH4-0}" -eq 1 ]; then
      shopt "${_opt:--u}" inherit_errexit
    fi
  fi
}

#######################################
# get value of var with eval from argument or stdin
# Arguments:
#   [variable]    variable name (default: stdin)
# Returns:
#   1 if variable is not defined
#######################################
value() {
  variable="${1:-"$(cat </dev/stdin)"}"
  set | grep -q "^${variable}=" || die Undefined Variable: "${variable}"
  eval echo "\$${variable}"
}

#######################################
# trap set by 'xtrace'
# Globals:
#   EXIT_XTRACE
#   QQUIET
# Arguments:
#   None
#######################################
_xtrace() {
  # set -u err not caught in signal EXIT.
  # if lsof is posix then use: stderr="$(lsof -d2 | grep $$ | awk '{ print $NF }')"
  rc=$?

  if test -s "${EXIT_XTRACE-}" && [ "${QQUIET-0}" -eq 0 ]; then
    >&2 echo
    >&2 LC_ALL=C tr -dc '\0-\177' < "${EXIT_XTRACE}" | sed "s/^\(+\)\1\{0,\} /$(magenta 'debug>  &')/g"
  fi
  exit $rc
}

#######################################
# sets trap with '_xtrace' function on EXIT and redirects 'set -x' to FD 19 for BASH
# Globals:
#   BASH4
#   EXIT_XTRACE
# Arguments:
#   None
# Examples:
#   . helpers.sh && xtrace
# Notice:
#   If shells started with sh will not show the output separated (i.e: sudo)
#######################################
xtrace() {
  if [ "${BASH4}" -eq 1 ] && [ ! "${EXIT_XTRACE-}" ]; then
    EXIT_XTRACE="$(mktemp)"; export EXIT_XTRACE
    # shellcheck disable=SC3023
    exec 19>"${EXIT_XTRACE}"
    export BASH_XTRACEFD=19
    trap _xtrace EXIT
  fi
}

#######################################
# show warning message unless QUIET is set to 1
#######################################
warning() { stack "${Warning}" "$@"; }

#######################################
# Strict mode and debugging
[ "${STRICT-1}" -eq 0 ] || [ "${PS1-}" ] || strict
[ "${STDERR-0}" -eq 0 ] || stderr
[ "${XTRACE-0}" -eq 0 ] || { set -x; xtrace; export SHELLOPTS; }
[ "${XVERBOSE-0}" -eq 0 ] || { set -v; export SHELLOPTS; }

####################################### Executed
#
if [ "${0##*/}" = 'helper.sh' ]; then
  fromman "$0" "$@" || exit 0
fi
