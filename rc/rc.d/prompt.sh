# shellcheck shell=sh

# Forces RC_PROMPT even if starship or zsh prompt are configured.
#
export RC_PROMPT="${RC_PROMPT:-0}"

PS2="$(prompt ps2 "${SH}")"

if cmd starship && [ "${RC_PROMPT-0}" -eq 0 ] && [ "${__rc_hook-}" ]; then
  _title () { prompt title; }
  . "${RC_D}/prompt/starship/${__rc_hook}"
  eval "$(starship init "${__rc_hook}")"
else
  PS2="$(prompt ps2 "${SH}")"
  . "${RC_D}/prompt/rc/${__rc_hook:-posix}"
fi
