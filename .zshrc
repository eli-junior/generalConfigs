export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="spaceship"

plugins=(zsh-autosuggestions zsh-syntax-highlighting git z)

source $ZSH/oh-my-zsh.sh

# Utils
_md () {
  mkdir $1 && cd $1
}
#
# Aliases
alias md=_md
alias vi=nvim
alias vim=nvim
alias please=sudo
alias manage='python manage.py'
alias gs='git status'
alias gcm='git commit -m'
alias gaa='git add --all'
alias gb='git branch'
alias gps='git push'
alias gp='git pull'
alias gitclean='find . | grep .git | xargs rm -rf'

# UV Python Configuration
. "$HOME/.local/bin/env"

# NVM Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

clear
