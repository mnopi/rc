#!/bin/sh
# shellcheck disable=SC3043,SC3030,SC3006,SC3024,SC3018,SC3010,SC3028

#
# helper shell library (sets bash strict mode by default).

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
STRICT="${STRICT:-1}"

# Sets shell xtrace 'set -x' when 1 (default: 0)
#
XTRACE="${XTRACE-0}"

# Sets shell verbose 'set -x' when 1 (default: 0)
#
XVERBOSE="${XVERBOSE-0}"

# caller stack, except 0 for stack() function
#
export STACK

# functions to exclude from stack when asking for the first useful
#
STACK_EXCLUDE="debug|die|error|verbose"

#######################################
# helper function for functions that use caller.
# Globals:
#   CALLER             Valid caller output
# Arguments:
#   1       Symbol
#   2       Color value
#######################################
call() {
  if [ "${BASH_VERSION-}" ]; then
    a
  else
    file="$(basename "$(psargs '' | awk '{ print $1 }')" 2>/dev/null || true)"
  fi
}

#######################################
# helper function for functions that use caller.
# Globals:
#   CALLER             Valid caller output
# Arguments:
#   1       Symbol
#   2       Color value
#######################################
_fileline() {
  printf '%b' "$1"; shift
  color="$1"; shift
  if [ "${CALLER-}" ]; then
    file="$(basename "$(echo "${CALLER}" | awk '{ print $3 }')")"
    line="$(echo "${CALLER}" | awk '{ print $1 }')"
  else
    file="$(basename "$(psargs '' | awk '{ print $1 }')" 2>/dev/null || true)"
  fi
  [ ! "${file-}" ] || printf '%b' " ${color}${file}${Reset}${line:+[${color}${line}${Reset}]}"
  printf '%b\n' " $*"
}

#######################################
# show info message with > symbol in grey  if DEBUG is set to 1, unless QUIET is set to 1
# Globals:
#   DEBUG              Show if DEBUG set to 1, unless QUIET is set to 1 (default: 0).
#   QUIET              Do not show message if set to 1, takes precedence over VERBOSE/DRY_RUN (default: 0).
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
# Output:
#   Message to stderr.
#######################################
debug() {
  fromman debug "$@" || exit 0

  # <html><h2>Show Debug Messages</h2>
  # <p><strong><code>$DEBUG</code></strong> (Default: 0).</p>
  # <p><strong><code>Debug messages are shown if set to 1.</code></strong></p>
  # <p>Activate with either of:</p>
  # <ul>
  # <li><code>DEBUG=1</code></li>
  # <li><code>--debug</code></li>
  # </ul>
  # </html>
  DEBUG="${DEBUG:-0}"

  if [ "${QUIET-0}" -ne 1 ] && [ "${DEBUG-}" -eq 1 ]; then
    add=''; content=''; line=''; sep=' '
    sets="$(set +o | tr '\n' ';')"
    set +o nounset  # set +u
    add=""; content=""; suffix=""
    if command -v caller >/dev/null; then
      index=0
      while c="$(caller "${index}")"; do
        if [ "$(echo "${c}" | awk '{ print $2 }')" = 'die' ] \
          || [ "$(basename "$(echo "${c}" | awk '{ print $3 }')")" = 'helper.sh' ]; then
          index="$((index+1))"
        else
          break
        fi
      done
      file="$(basename "$(echo "${c}" | awk '{ print $3 }')")"
      line="$(echo "${c}" | awk '{ print $1 }')"
    fi

    [ "${file-}" ] || file="$(basename "$(psargs '' | awk '{ print $1 }')" 2>/dev/null || true)"
    [ ! "${file-}" ] || add="$(greyinvert "${file}${line:+[${line}]}"): "

    for arg do
      content="${content}${suffix}${arg}=$(eval echo "\$${arg}")"
      suffix=", "
    done

    if [ ! "${content}" ] && [ "${add-}" ]; then
      add="${add%??}" # if no args, remove trailing ": "
    elif [ ! "${content}" ]; then
      sep=''
    fi

    >&2 printf '%b\n' "$(grey '+')${sep}${add}$(greydim "${content}")" >&2
    eval "${sets}"  # set -u, if it was set before
    unset add arg c content sep sets suffix
  fi
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
  fromman die "$@" || exit 0

  if [ "${QUIET-0}" -ne 1 ]; then
    case "${rc}" in
      0) success "$@" ;;
      *) error "$@" ;;
    esac
  fi
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
# Globals:
#   CALLER             Valid caller output
#   QUIET              Do not show message if set to 1, takes precedence over VERBOSE/DRY_RUN (default: 0).
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
# Output:
#   Message to stderr.
#######################################
error() {
  fromman error "$@" || exit 0

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
  QUIET="${QUIET:-0}"

  [ "${QUIET-0}" -eq 0 ] || stack "${Error}" "${Red}" 1 1 "$@"
}

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
#######################################
psargs() {
  fromman psargs "$@" || exit 0

  if command -v ps >/dev/null; then
    if ! ps -p $$ -o args= 2>/dev/null; then
      ps -o pid= -o args= | awk '/$$/ { $1=$1 };1' | grep "^$$ " | cut -d '' -f 2-
    fi
  fi
}

#######################################
# show message based on return code to stdout (can be used with 'stderr' or 'xtrace' to show error first
# Arguments:
#   [--warning]   print warning
# Returns:
#   based on previous exit code
#######################################
show() {
  ret=$?
  export PROMPT_EOL_MARK=''
  case "${1-}" in
    Critical) printf '%b' "${Critical}"; ret="${1}"; shift ;;
    Error) printf '%b' "${Error}"; ret="${1}"; shift ;;
    --finish) green "=>"; ret="${1}"; shift ;;
    Notice) printf '%b' "${Notice}"; ret="${1}"; shift ;;
    --ok) printf '%b' "${Ok}"; ret="${1}"; shift ;;
    --options) echo "critical" ;;
    --start) blue "=>"; ret="${1}"; shift ;;
    Success) printf '%b' "${Success}"; ret="${1}"; shift ;;
    Verbose) printf '%b' "${Verbose}"; ret="${1}"; shift ;;
    Warning) printf '%b' "${Warning}"; ret="${1}"; shift ;;
  esac

  case $ret in
    --*) ret=0 ;;
    0) printf '%b' "${Ok}" ;;
    *) printf '%b' "${Error}" ;;
  esac

  if [ $# -eq 0 ]; then
    return $ret
  elif [ $# -gt 1 ]; then
    italic "$1 "
  fi
  printf '%s\n' " $*"
  return $ret
}

#######################################
# caller stack, except 0 for this function or return first which does not have func or file.
# returns ps file if no BASH
# Globals:
#   STACK
# Arguments:
#   1       Symbol
#   2       Color value
#   3       Regex exclude filename, 1 to use default exclusion.
#   4       Regex exclude functions, 1 to use default exclusion.
#   @       Arguments to print.
#######################################
# shellcheck disable=SC2120
stack() {
  filter=false
  if [ "${1-}" ]; then
    filter=true
    symbol="$(printf '%b' "$1")"
    color="$2"
    if [ "${BASH_VERSION-}" ]; then
      files="${BASH_SOURCE[0]##*/}"
      [ "$3" -eq 1 ] || files="${1}|${files}"
      [ "$4" -eq 1 ] || funcs="${2}|${STACK_EXCLUDE}"
    else
      file="$(basename "$(psargs '' | awk '{ print $1 }')" 2>/dev/null || true)"
      [ ! "${file-}" ] || sep=" "
      file=" $(printf '%b' "${color}${file}${Normal}")${sep}"
    fi
    shift 4
  fi

  if [ "${BASH_VERSION-}" ]; then
    declare -i i=1
    [ "${STACK-}" ] || export STACK=()
    local frame line func file value
    while frame="$(caller "$i")"; do
      if $filter; then
        line="$(echo "${frame}" | awk '{ print $1 }')"
        func="$(echo "${frame}" | awk '{ print $2 }')"
        file="$(basename "$(echo "${frame}" | cut -d ' ' -f3-)")"
        if [[ "${file}" =~ ${files} ]] || [[ "${func}" =~ ${funcs:-${STACK_EXCLUDE}} ]]; then
          continue
        else
          file=" $(printf "%b" "${color}${file}${Normal}[${color}${line}${Normal}]") "
          break
        fi
      else
        STACK+=("${c}")
      fi
      ((i++))
    done
  fi
  ! $filter || printf "%s\n" "${symbol}${file}$(FirstArg "$@")"
  echo
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
  # Quiets any stderr/$XTRACE/$XVERBOSE when 1 (default: 0)
  #
  QQUIET="${QQUIET-0}"

  if test -s "${EXIT_STDERR-}"; then
    # Unset debug so grep unbound works and grep + 2 times just in case set -x and set +x was put in the middle.
    if grep -q -m2 '^\+\{0,\} ' "${EXIT_STDERR}"; then
      was_debug=1
    fi

    if [ $rc -eq 0 ] && grep -q ': unbound variable$|: parameter null or not set' "${EXIT_STDERR}"; then
      rc=1
    fi

    if { [ "${was_debug-0}" -eq 1 ] || [ $rc -ne 0 ]; } && [ "${QQUIET-0}" -eq 0 ]; then
      echo
      # https://unix.stackexchange.com/questions/475548/removing-all-non-ascii-characters-from-a-workflow-file
      LC_ALL=C tr -dc '\0-\177' < "${EXIT_STDERR}" | sed "s/^\(+\)\1\{0,\} /$(magenta 'debug>  &')/g; \
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
  last="$(magenta "${BASH_COMMAND}")"
  echo "$(show --error) ${BASH_SOURCE[1]}:${BASH_LINENO[0]} ${last} ($(red $code))"
  if [ ${#FUNCNAME[@]} -gt 2 ]; then
    echo "   ${BASH_SOURCE[1]} Traceback (most recent call first):"
    for ((i=0; i < ${#FUNCNAME[@]} - 1; i++)); do
      funcname="$(green "${FUNCNAME[$i]}")"
      [ "$i" -ne "0" ] || funcname="${last}"
      echo "   ${BASH_SOURCE[$i + 1]}:${BASH_LINENO[$i]} ${funcname}"
    done
  fi
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
      trap _strict "${TRAP_SIGNAL}"
    fi
    set "${_set:-+o}" errtrace
    set "${_set:-+o}" pipefail
    if [ "${BASH4-0}" -eq 1 ]; then
      shopt "${_opt:--u}" inherit_errexit
    fi
  fi
}

#######################################
# show success message in white with green ✓ symbol, unless QUIET is set to 1
# Globals:
#   QUIET              Do not show message if set to 1, takes precedence over VERBOSE/DRY_RUN (default: 0).
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
# Output:
#   Message to stderr.
#######################################
success() {
  fromman success "$@" || exit 0

  if [ "${QUIET-0}" -ne 1 ]; then
    sep=''
    [ "$#" -eq 0 ] || sep=' '
    >&2 printf '%b\n' "$(green ✔)${sep}$*"
    unset sep
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
# show verbose/dry-run message with > symbol in grey dim if VERBOSE or DRY_RUN are set, unless QUIET is set to 1
# Globals:
#   DRY_RUN            Show message if set to 1, unless QUIET is set to 1 (default: 0).
#   QUIET              Do not show message if set to 1, takes precedence over VERBOSE/DRY_RUN (default: 0).
#   VERBOSE            Shows message if set to 1, unless QUIET is set to 1 (default: 0).
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
# Output:
#   Message to stderr.
#######################################
verbose() {
  fromman verbose "$@" || exit 0

  # <html><h2>Dry Run</h2>
  # <p><strong><code>$DRY_RUN</code></strong> (Default: 0).</p>
  # <p>Activate with either of:</p>
  # <ul>
  # <li><code>DRY_RUN=1</code></li>
  # <li><code>--dryrun</code></li>
  # </ul>
  # </html>
  DRY_RUN="${DRY_RUN:-0}"

  # <html><h2>Show Verbose Messages</h2>
  # <p><strong><code>$VERBOSE</code></strong>  (Default: 0).</p>
  # <p><strong><code>Verbose messages are shown if set to 1.</code></strong></p>
  # <p>Activate with either of:</p>
  # <ul>
  # <li><code>VERBOSE=1</code></li>
  # <li><code>--verbose</code></li>
  # </ul>
  # </html>
  VERBOSE="${VERBOSE:-0}"

  if [ "${QUIET-0}" -ne 1 ] && { [ "${VERBOSE}" -eq 1 ] || [ "${DRY_RUN-}" -eq 1 ]; }; then
    sep=''
    [ "$#" -eq 0 ] || sep=' '
    >&2 printf '%b\n' "$(cyan '>')${sep}$(cyandim "$*")"
    unset sep
  fi
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
  #set +xv

  # Quiets any stderr/$XTRACE/$XVERBOSE when 1 (default: 0)
  #
  QQUIET="${QQUIET-0}"

  if test -s "${EXIT_XTRACE-}" && [ "${QQUIET-0}" -eq 0 ]; then
    echo
    LC_ALL=C tr -dc '\0-\177' < "${EXIT_XTRACE}" | sed "s/^\(+\)\1\{0,\} /$(magenta 'debug>  &')/g"
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
# show warning message with ! symbol in yellow if WARNING is set to 1, unless QUIET is set to 1
# Globals:
#   QUIET              Do not show message if set to 1, takes precedence over VERBOSE/DRY_RUN (default: 0).
#   WARNING            Shows message if is set to 1, unless QUIET is set to 1 (default: 0).
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
# Output:
#   Message to stderr.
#######################################
warning() {
  fromman warning "$@" || exit 0

  # <html><h2>Show Warning Messages</h2>
  # <p><strong><code>$WARNING</code></strong>  (Default: 0).</p>
  # <p><strong><code>Warning messages are shown if set to 1.</code></strong></p>
  # <p>Activate with either of:</p>
  # <ul>
  # <li><code>WARNING=1</code></li>
  # <li><code>--warning</code></li>
  # </ul>
  # </html>
  WARNING="${WARNING:-0}"

  if [ "${QUIET-0}" -ne 1 ] && [ "${WARNING}" -eq 1 ]; then
    add=''; line=''; sep=' '
    if command -v caller >/dev/null; then
      index=0
      while c="$(caller "${index}")"; do
        if [ "$(echo "${c}" | awk '{ print $2 }')" = 'die' ] \
          || [ "$(basename "$(echo "${c}" | awk '{ print $3 }')")" = 'helper.sh' ]; then
          index="$((index+1))"
        else
          break
        fi
      done
      file="$(basename "$(echo "${c}" | awk '{ print $3 }')")"
      line="$(echo "${c}" | awk '{ print $1 }')"
    fi

    [ "${file-}" ] || file="$(basename "$(psargs '' | awk '{ print $1 }')" 2>/dev/null || true)"
    [ ! "${file-}" ] || add="$(yellowinvert "${file}${line:+[${line}]}"): "

    if [ "$#" -eq 0 ]&& [ "${add-}" ]; then
      add="${add%??}" # if no args, remove trailing ": "
    elif [ "$#" -eq 0 ]; then
      sep=''
    fi

    >&2 printf '%b\n' "${YellowMark}${sep}${add}$(yellow "$*")" >&2
    unset add c file line sep
  fi
}

#######################################
# Strict mode and debugging
. shell.sh || return 1 2>/dev/null || exit 1
[ "${STRICT-1}" -eq 0 ] || [ "${PS1-}" ] || strict
[ "${STDERR-0}" -eq 0 ] || stderr
[ "${XTRACE-0}" -eq 0 ] || { set -x; xtrace; export SHELLOPTS; }
[ "${XVERBOSE-0}" -eq 0 ] || { set -v; export SHELLOPTS; }

####################################### Executed
#
if [ "${0##*/}" = 'helper.sh' ]; then
  fromman "$0" "$@" || exit 0
fi
