#!/bin/sh
# shellcheck disable=SC2034

#
# https://git-scm.com/docs/git-sh-setup
# https://github.com/git/git/blob/master/git-sh-setup.sh
# Stuck long form:
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

set -e
. helper.sh
. cmd.sh_parseopt="git rev-parse --parseopt --stuck-long"
_script="${0##*/}"

# git-sh-setup: keep the `--` is an arg when is written as an argument: git-example -- argument (will have -- and --)
# (Default: 0)
: "${OPTIONS_KEEPDASHDASH=0}"; [ "${OPTIONS_KEEPDASHDASH}" -eq 0 ] || _parseopt="${_parseopt} --keep-dashdash"

# Stop parsing after the first non-option argument, so errors after that are not caught.
# git-parse -Ca stop --foo --bar -- a  -> --bar would not give error if not in spec.
# (Default: 0)
: "${OPTIONS_STOPATNONOPTION=0}";[ "${OPTIONS_STOPATNONOPTION}" -eq 0 ] || _parseopt="${_parseopt} --stop-at-non-option"

# Color Command from $0: 'git-example'
#
SCRIPT="$(green "${_script}")"

# Color Command from $0 Removing 'git-': 'example'
#
COMMAND="$(green "${_script##*git-}")"

# Color Git Command from $0 Splitting  git': 'git example'
#
GIT_COMMAND="$(green "git ${COMMAND}")"; [ "git-${_script##*git-}" = "${_script}" ] || GIT_COMMAND="${SCRIPT}"

#######################################
# private spec for git-parse.sh/git-parse when not sourced
# Arguments:
#  None
#######################################
_spec() {
  cat <<EOF
${GIT_COMMAND} $(red "-h")
${SCRIPT} $(red "--help")
. ${SCRIPT}
. ${SCRIPT}$(green ".sh")
OPTIONS_KEEPDASHDASH=1 . ${SCRIPT}
OPTIONS_STOPATNONOPTION=1 . ${SCRIPT}

. ${SCRIPT} - Parsing using stuck long option if $(magenta spec\(\)) defined.
              Parsing $(magenta '-C <path') if defined in the options spec $(magenta '^C=path'), \
and change to $(magenta '<path>')

            Globals:
              $(magenta SCRIPT)       =>  $(green git-foo)
              $(magenta COMMAND)      =>  $(green foo)
              $(magenta GIT_COMMAND)  =>  $(green 'git foo')

            Defaults:
              $(magenta OPTIONS_KEEPDASHDASH)     =>  $(blue 0)
              $(magenta OPTIONS_STOPATNONOPTION)  =>  $(blue 0)

            Stuck Long \$OPTIONS_SPEC:
              f,foo       $(magenta '-f --foo --no-foo')             =>  $(blue '-f --foo --no-foo')
              m,moo!      $(magenta '-m --moo')                      =>  $(blue '--moo --moo')
              b,bar=      $(magenta '-bbar1 --bar bar2 --bar=bar3')  =>  \
$(blue '--bar=bar1 --bar=bar2 --bar=bar3')
              q,qux?path  $(magenta '--qux -qquix1 --qux=qux2')      =>  $(blue '--qux --qux=quix1 --qux=qux2')
              continue!   $(magenta '--continue')                    =>  $(blue '--continue')
              a,abort!    $(magenta '-a --abort')                    =>  $(blue '--abort --abort')
              A!path      $(magenta '-A')                            =>  $(blue '-A')
              C=path      $(magenta '-C c')                          =>  $(blue '-Cc')
              E?path      $(magenta '-E -Ee')                        =>  $(blue '-E -Ee')

            Stuck Long Parser:
              $(magenta 'while') $(magenta '[') $(red "\$#") -ne 0 $(magenta ']'); $(magenta "do")
                $(magenta case) $(blue "\"")$(yellow "\$1")$(blue "\"") $(magenta in)
                  --foo) $(red "foo")=$(blue "\"\$((")foo+$(blue "1))\"") $(magenta ";;")
                  --no-foo) $(red "foo_no")=1 $(magenta ";;")
                  --moo) $(red "moo")=1 $(magenta ";;")
                  --bar=*) $(red "bar")=$(blue "\"\${")bar:+$(green "\${")bar$(green "}") \
$(blue "}\${")$(yellow 1)#$(yellow "--bar=")$(blue "}\"") $(magenta ";;")
                  --qux) $(red "qux")=true $(magenta ";;")
                  --qux=*) $(red "qux_values")=$(blue "\"\${")qux_values:+$(green "\${")\
qux_values$(green "}") $(blue "}\${")$(yellow 1)#$(yellow "--qux=")$(blue "}\"") \
$(magenta ";;")
                  --continue) $(red "continue")=1 $(magenta ";;")
                  --abort) $(red "abort")=1 $(magenta ";;")
                  -A) $(red "A")=1 $(magenta ";;")
                  -C*) $(red "C")="${1#-C}" $(magenta ";;")
                  -C*) $(red "C")=$(blue "\"\${")$(yellow 1)#$(yellow "-E")$(blue "}\"") \
      $(magenta ";;")
                  -E) $(red "E")=true $(magenta ";;")
                  -E*) $(red "E_value")=$(blue "\"\${")E_value:+$(green "\${")E_value$(green "}") \
$(blue "}\${")$(yellow 1)#$(yellow "-E")$(blue "}\"") $(magenta ";;")
                  --) $(cyan 'shift'); $(cyan 'break') $(magenta ";;")
                $(magenta 'esac')
                $(cyan 'shift')
              $(magenta 'done')

              $(green "\$") git-parse @1 -f --foo --no-foo --moo @2 -bbar1 --bar bar2 --bar=bar3 @3 \
--qux -qquix1 --qux=qux2 @4 -A -C c -E -Ee @5 --continue @6 -a --abort -- DASH
              $(blue "A=1 C=c E=true E_value=e abort=1 bar='bar1 bar2 bar3' continue=1 foo=2 foo_no=1 moo=1 \
qux=true qux_values='quix1 qux2'")
              $(blue "\$@=@1 @2 @3 @4 @5 @6 DASH")

            Helper Functions:
              $(magenta 'invalid()')   =>  $(blue 'show invalid argument/option value message and exit')
              $(magenta 'required()')  =>  $(blue 'show argument required message and exit')
--
h,help    Show help and exit.
EOF
}

#######################################
# show invalid argument/option value message and exit
# Arguments:
#  [<value>]       invalid argument value, i.e: 'foo'
#  [<argument>]    argument name, i.e: "<remote>"
#######################################
invalid() {
  red "$1"
  echo "invalid argument/option value for ${2}"
  "$0" -h
}

#######################################
# show argument required message and exit
# Arguments:
#  [<name>]       argument name, i.e: "<submodule name>'
#######################################
required() {
  red "$1"
  echo "argument requires a value"
  "$0" -h
}

case "${0##*/}" in
  git-parse*) _spec=_spec ;;
  *) ! cmd spec || _spec=spec ;;
esac

if [ "${_spec-}" ]; then
  eval "$($_spec | ${_parseopt} -- "$@" || echo exit $?)"

  #######################################
  # change to directory in -C option if specified on the spec (C=path) and removes from parsed arguments.
  # Arguments:
  #  None
  #######################################
  if $_spec | grep -q "^C=path"; then
    for arg; do
      shift
      case "${arg}" in
        -C*) cd "${arg#-C}" ;;
        *) set -- "$@" "${arg}" ;;
      esac
    done
  fi
fi
