# BASH_COMPLETION_VERSINFO only in sourced
if [ "${BASH_COMPLETION_VERSINFO-}" ] || command -v bashcompinit >/dev/null; then
  true
fi
# ZSH to use bash_completion
# autoload -U +X compinit && compinit
# autoload -U +X bashcompinit && bashcompinit
# https://computingforgeeks.com/how-to-source-bash-completion-script-file-in-zsh/
# https://stackoverflow.com/questions/67136714/how-to-properly-call-compinit-and-bashcompinit-in-zsh
