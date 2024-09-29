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
alias cat="/bin/bat --color=auto"
alias bat="/bin/cat"
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
alias pipclean='pip freeze | xargs pip uninstall -y'
alias gitclean='find . | grep .git | xargs rm -rf'
alias venv='pyenv virtualenv 3.11'

# Pyenv Configuration. See https://github.com/pyenv/pyenv for more information
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# NVM Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


### PENGWIN BEGIN ###
. $HOME/.pengwinrc
### PENGWIN END ###
clear
