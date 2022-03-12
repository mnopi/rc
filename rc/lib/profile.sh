# shellcheck shell=sh

#
# Appended to /etc/profile during installation of rc

umask 002

# Check to only run once
if [ "${RC_D-}" != "${RC?Source it from 'profile' or set \$RC to be sourced from 'profile.sh'}/rc.d" ] ; then
  # RC completions: sourced by $RC_PROFILE at the end
  #
  export RC_COMPLETIONS_D="${RC}/completions.d"

  # rc.d compat dir:  sourced $RC_PROFILE_SH after pathsd (libs and bin)
  #
  export RC_D="${RC}/rc.d"

  # RC $PATH compat dir: sourced in order by $RC_PROFILE after $RC_PROFILE_D,
  # they can have a variable already defined in $RC_PROFILE_D
  #
  export RC_PATHS_D="${RC}/paths.d"

  # RC profile.d compat dir: everything that is exported (only run once), sourced by $RC_PROFILE_SH
  #
  export RC_PROFILE_D="${RC}/profile.d"

  # RC share (not exported)
  #
  export RC_SHARE="${RC}/share"

  for i in "${RC_PROFILE_D}"/*; do
    . "${i}"
  done

  eval "$("${RC}/bin/pathsd")"
fi

. cmd.sh
. shell.sh

for i in "${RC_D}"/*.sh; do
  . "${i}"
done

if [ "${BASH_VERSINFO-}" ]; then
  for i in "${RC_D}"/*.bash; do
    . "${i}"
  done
fi

#if [ "${SOURCED_BASH}" -eq 0 ]; then
#  unset -f _direnv_hook starship_precmd
#elif [ "${BASH_VERSINFO-}" ]; then
#  for i in "${RC_D}"/*.bash; do
#    . "${i}"
#  done
#fi


# TODO: Meter lo de history append, lo de comprobar que ya esta la variable para todo menos para el PS1
#   Meter el PS1 ya de una puta vez, terminar el container. Aglutinar las variables en un fichero para que solo
#   se pregunte una vez y preguntar solo por UNAME en todas menos en las que se tienen que cargar en RC.
#   Habrá que hacer lo de .profile y .bashrc de cada usuario.
