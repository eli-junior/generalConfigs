# ==============================
# Zsh Profile - Eli
# Oh My Posh + qualidade de vida
# ==============================

# Encoding melhor para terminal moderno
export LANG="${LANG:-C.UTF-8}"
export LC_ALL="${LC_ALL:-C.UTF-8}"

# PATH local
export PATH="$HOME/.local/bin:$PATH"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="spaceship"
plugins=(git z zsh-autosuggestions zsh-syntax-highlighting)
[[ -s "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# Oh My Posh
if command -v oh-my-posh >/dev/null 2>&1; then
  theme="${POSH_THEMES_PATH:-}/jandedobbeleer.omp.json"

  if [[ -n "$POSH_THEMES_PATH" && -f "$theme" ]]; then
    eval "$(oh-my-posh init zsh --config "$theme")"
  else
    eval "$(oh-my-posh init zsh)"
  fi
else
  print -P "%F{yellow}oh-my-posh nao encontrado. Instale com: winget install JanDeDobbeleer.OhMyPosh%f"
fi
unset theme

# Autocomplete e historico melhorado
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt append_history
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt inc_append_history

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zmodload zsh/complist 2>/dev/null

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey '^I' menu-select
bindkey '^D' delete-char-or-list
bindkey '^Z' undo
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# Aliases uteis
alias ll='ls -lh'
alias la='ls -la'
alias g='git'
alias c='clear'
alias vi='nvim'
alias vim='nvim'
alias please='sudo'
alias manage='python manage.py'

# Navegacao
function .. {
  cd ..
}

function ... {
  cd ../..
}

function home {
  cd "$HOME"
}

function docs {
  if [[ -d "$HOME/Documents" ]]; then
    cd "$HOME/Documents"
  elif [[ -d "/mnt/c/Users/eli/Documents" ]]; then
    cd "/mnt/c/Users/eli/Documents"
  else
    print -P "%F{yellow}Diretorio Documents nao encontrado.%f"
    return 1
  fi
}

function reload-profile {
  source "$HOME/.zshrc"
  print -P "%F{green}Profile recarregado.%f"
}

function edit-profile {
  code "$HOME/.zshrc"
}

# Mostra onde esta um comando especifico
function which {
  if [[ $# -eq 0 ]]; then
    print "uso: which <comando>"
    return 1
  fi

  whence -v "$@"
}

# Lista comandos disponiveis, com filtro opcional
function commands {
  local filter="${1:-*}"
  whence -pm "$filter" | sort
}

# Versao formatada para explorar comandos
function cmds {
  local filter="${1:-*}"
  whence -pm "$filter" | sort | column
}

function mkcd {
  if [[ $# -eq 0 ]]; then
    print "uso: mkcd <diretorio>"
    return 1
  fi

  mkdir -p "$1" && cd "$1"
}

# Git helpers
function gs {
  git status
}

function ga {
  git add .
}

function gcmsg {
  if [[ $# -eq 0 ]]; then
    print "uso: gcmsg <mensagem>"
    return 1
  fi

  git commit -m "$*"
}

function gp {
  git push
}

function gl {
  git log --oneline --graph --decorate -n 15
}

# UV Python Configuration
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# NVM Configuration
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# SDKMAN Configuration
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# Info inicial discreta
clear
print ""
print -P "%F{cyan}Zsh pronto, Eli.%f"
print -P "%F{8}Perfil: $HOME/.zshrc%f"
