#!/bin/sh
cd "$(dirname "$0")"/../.. || exit

if [ "${1-}" ]; then
  "$1" -c ". ./lib/shell.sh && echo \${SH}"
else
  . ./lib/shell.sh && printf '%s' "${SH}"
fi
