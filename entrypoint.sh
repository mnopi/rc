#!/bin/sh

export RC_PREFIX=/rc

[ ! -f "${RC_PREFIX}/rc/profile" ] || . "${RC_PREFIX}/rc/profile"
set -eu

# first arg is `-f` or `--some-option`
# or there are no args
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
  # docker run bash -c 'echo hi'
  exec /bin/sh "$@"
fi

exec "$@"
