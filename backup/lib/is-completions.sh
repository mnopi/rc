# BASH_COMPLETION_VERSINFO only in sourced
if [ "${BASH_COMPLETION_VERSINFO-}" ] || command -v bashcompinit >/dev/null; then
  true
fi
# ZSH to use bash_completion
# autoload -U +X compinit && compinit
# autoload -U +X bashcompinit && bashcompinit
# https://computingforgeeks.com/how-to-source-bash-completion-script-file-in-zsh/
# https://stackoverflow.com/questions/67136714/how-to-properly-call-compinit-and-bashcompinit-in-zsh
if [ "x${BASH_VERSION-}" != x -a "x${PS1-}" != x -a "x${BASH_COMPLETION_VERSINFO-}" = x ]; then

    # Check for recent enough version of bash.
    if [ "${BASH_VERSINFO[0]}" -gt 4 ] ||
        [ "${BASH_VERSINFO[0]}" -eq 4 -a "${BASH_VERSINFO[1]}" -ge 2 ]; then
        [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/bash_completion" ] &&
            . "${XDG_CONFIG_HOME:-$HOME/.config}/bash_completion"
        if shopt -q progcomp && [ -r /usr/share/bash-completion/bash_completion ]; then
            # Source completion code.
            . /usr/share/bash-completion/bash_completion
        fi
    fi

fi
