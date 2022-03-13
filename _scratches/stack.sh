#!/bin/bash

stack() {
  declare -i i="${1:-1}"
  [ "${STACK-}" ] || STACK=()
  local c caller=()
  while c="$(caller "$i")"; do
    STACK+=("${c}")
    ((i++))
  done
  declare -p STACK
  echo
}

a1() { stack ''; a2; }
a2() { stack; a3; }
a3() { stack; }
a() { stack; a1; }

a

