#!/bin/sh

export ENV=/etc/profile
! test -d /rc || { export RC_PREFIX=/rc; export ENV=/rc/profile; }

set -eu

if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ] || \
  type "$1" 2>/dev/null | grep -q -E "is a function|is aliased to|is a shell keyword"; then
  # first arg has '-' (`-f` or `--some-option`): `container run alpine -c 'echo hi'`
  # or there are no args: `container run alpine`
  # or f is a function (can not exec)
  # or l is aliased to 'ls' (can not exec)
  # or for,if,[,!,{ is a shell keyword (can not exec): `container run alpine if true; echo true; fi`
  exec /bin/sh "$@"
fi

# echo is a shell builtin: `container run alpine echo hi`
# ls is /bin/ls: `container run alpine ls`
# ... etc.: `container run cmd ls`
exec "$@"
