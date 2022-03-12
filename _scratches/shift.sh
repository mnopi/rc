#!/bin/sh

spec() {
  cat <<EOF
git-parse [<options>] <args>...

git-parse does foo and bar, EVERYTHING in SPEC will be in \$@ before '--' and any words not in spec are after --
--
h,help    show the help ('git parse --help' only if manual page, git-parse --help will show the message)

f,foo       some nifty option --foo
m,moo!      some nifty option --moo not negate (like actions, non-negate are called Actions)
b,bar=      some cool option --bar with an argument (could be '--bar bar' or '--bar=bar')
baz=arg   another cool option --baz with a named argument (--baz <arg> or --baz=<arg>)
q,qux?path  qux may take a path argument but has meaning by itself (--qux[=<path>]). \
  ! DO NOT CALL WITH '--qux <path>' since <path> will be after --

 Actions:
continue!          continue
a,abort!             abort and check out the original branch
skip!              skip current patch and continue

  An option group Header
A!path        -A \
              option A (like --foo: --A)
C=path        -C c \
              option C with an argument (like --baz but can not be used with '=' or 'git -C': must be separated, '-C c')
E?path        -E -Ee \
              option E with a named argument (like --qux: '-E' alone or '-Ee')
EOF
}

_spec=spec

if $_spec | grep -q "^C=path"; then
  for arg; do
    shift
    case "${arg}" in
      -C*) set -v; echo "${arg#-C}" ;;
      *) set -- "$@" "${arg}" ;;
    esac
  done
fi
echo "$@"
