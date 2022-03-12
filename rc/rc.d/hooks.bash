# shellcheck shell=bash


#######################################
# Parallel ENV
# https://www.gnu.org/software/parallel/env_parallel.html
#######################################
! cmd env_parallel.bash || cmd env_parset || . env_parallel.bash

if [ "${PS1-}" ]; then
  shopt -s checkwinsize
  shopt -s histappend

  #######################################
  # Exec Fail
  # a non-interactive shell will not exit if it cannot execute the file specified as an argument
  # to the exec builtin command. An interactive shell does not exit if exec fails.
  #######################################
  shopt -s execfail

  ! cmd direnv || cmd _direnv_hook || { eval "$(direnv hook bash)" && alias allow='direnv allow'; }

  #######################################
  # Homebrew Command Not Found
  # https://github.com/Homebrew/homebrew-command-not-found
  # BASH is checked in $HB_CNF_HANDLER
  #######################################
  [ ! -f "${HB_CNF_HANDLER?}" ] || cmd command_not_found_handle || . "${HB_CNF_HANDLER}"

  # TODO: ya esta el prompt.sh jodiendo cuando vas para atras en la historia o la linea es larga coño.
  # TODO: el que ode el prompt soy yo en ambos PS1 y el prompt !!!!
  # TODO: quitar el history de jedi pycharm
  # TODO: en terminal funcional las teclas españolas y en pycharm no.
  # TODO: recordar que estaba con lo del --forc de la url o no se que e hice lo del parser de git y me despiste.
  # TODO: sacar el prompt de aqui. y si l prompt_command no funciona en dash o busybox???
  case ps1 in
    git) . git-prompt.sh ;;
    prompt) . prompt.sh ;;
    ps1) . ps1.sh ;;
    starship) . starship.sh ;;
  esac

  PS2="\$(if [ \"\$(id -u)\" -eq 0 ]; then magenta \"> \"; else green \"> \"; fi)"
fi
