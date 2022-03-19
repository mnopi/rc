# shellcheck shell=sh

rebash() { unset PROFILE_SOURCED PROFILE_SH_SOURCED RC_SH_SOURCED; . "${ENV?}"; }
