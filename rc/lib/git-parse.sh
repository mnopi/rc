#!/bin/sh

#
# https://git-scm.com/docs/git-sh-setup
# https://github.com/git/git/blob/master/git-sh-setup.sh

set -eu

# git-sh-setup: keep the `--` is an arg when is written as an argument: git-example -- argument (will have -- and --)
# Everything in the
OPTIONS_KEEPDASHDASH="${OPTIONS_KEEPDASHDASH-}"

# Stop parsing after the first non-option argument, so errors after that are not caught.
# git-parse -Ca stop --foo --bar -- a  -> --bar would not give error if not in spec.
OPTIONS_STOPATNONOPTION="${OPTIONS_STOPATNONOPTION:---stop-at-non-option}"

# git-sh-setup: Output in stuck long form:
# If not set (long converted to short if both in the spec):
#     --foo => -f (if f,foo otherwise or --foo)
#     -f => -f
#     --bar bar1 --bar=bar2 => --bar bar1 --bar bar2
#     --qux --qux=qux => --qux --qux qux
#     -C c => -C c
#     -Ee => -E e
# If set (short converted to long if both in the spec):
#     -f => --foo
#     --foo => --foo
#     --bar bar1 --bar=bar2 => --bar=bar1 --bar=bar2
#     --qux --qux=qux => --qux --qux=qux
#     -C c => -Cc
#     -Ee => -Ee
OPTIONS_STUCKLONG="${OPTIONS_STUCKLONG-}"

# git-sh-setup: Git Parse Options Specification
#
OPTIONS_SPEC="${OPTIONS_SPEC-}"

# git-sh-setup: Long Usage if $OPTIONS_SPEC is not set. It is added to $USAGE in usage()
#
LONG_USAGE="${LONG_USAGE-}"

# git-sh-setup: If it is not set, it will exit if we are not on a git dir.
# The below sets the variable to 1 if undefined, otherwise keeps the value.
: "${NONGIT_OK=1}"

# git-sh-setup: Can be set if the script can run from a subdirectory of the working tree (some commands do not)
#
SUBDIRECTORY_OK="${SUBDIRECTORY_OK:-1}"

# git-sh-setup: Usage if $OPTIONS_SPEC is not set. It is shown with usage().
#
USAGE="${USAGE-}"

# Color Command from $0: 'git-example'
#
SCRIPT="$(greenbold "${0##*/}")"

# Color Command from $0 Removing 'git-': 'example'
#
COMMAND="$(greenbold "${SCRIPT#git-}")"

# Color Git Command from $0 Splitting  git': 'git example'
#
GIT_COMMAND="$(greenbold "git ${COMMAND}")"

case "${0##*/}" in
  *parse*)
  OPTIONS_SPEC="$(cat <<EOF
${GIT_COMMAND} $(redbold "-h")
${SCRIPT} $(redbold "--help")
. ${SCRIPT}
OPTIONS_KEEPDASHDASH=1 . ${SCRIPT}
OPTIONS_STOPATNONOPTION=1 . ${SCRIPT}
OPTIONS_STUCKLONG=1 . ${SCRIPT}

${SCRIPT} - Parses arguments when sourced if $(magentabold \$OPTIONS_SPEC) or $(magentabold spec\(\)) defined.
            Use $(magentabold usage\(\)) after sourcing to parse $(redbold "-h") if $(magentabold \$OPTIONS_SPEC) \
and $(magentabold spec\(\)) are not defined.

            Globals: $(magentabold SCRIPT), $(magentabold COMMAND) and $(magentabold GIT_COMMAND).
            Provides helper functions from: $(git --exec-path)/git-sh-setup
--
h,help    Show help and exit.
EOF
)"
  eval "$(echo "${OPTIONS_SPEC}" | git rev-parse --parseopt -- "$@" || echo exit $?)"
  exit
  ;;
esac

if [ "${OPTIONS_SPEC-}" ] || cmd spec; then
  parseopt_extra=
  [ ! "${OPTIONS_KEEPDASHDASH-}" ] || parseopt_extra="--keep-dashdash"
  [ ! "${OPTIONS_STOPATNONOPTION-}" ] || parseopt_extra="${parseopt_extra} --stop-at-non-option"
  [ ! "${OPTIONS_STUCKLONG-}" ] || parseopt_extra="${parseopt_extra} --stuck-long"
  # shellcheck disable=SC2086
  eval "$(echo "${OPTIONS_SPEC-$(spec)}" | git rev-parse --parseopt ${parseopt_extra} -- "$@" || echo exit $?)"
fi

# shellcheck disable=SC2240
GIT_TEXTDOMAINDIR="" NONGIT_OK=${NONGIT_OK} SUBDIRECTORY_OK=${SUBDIRECTORY_OK} . "$(git --exec-path)"/git-sh-setup ""
