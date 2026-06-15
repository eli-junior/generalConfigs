#!/usr/bin/env bash
set -Eeuo pipefail

LOG_PREFIX="[generalConfigs]"

log() {
  printf '%s %s\n' "$LOG_PREFIX" "$*"
}

warn() {
  printf '%s WARN: %s\n' "$LOG_PREFIX" "$*" >&2
}

die() {
  printf '%s ERROR: %s\n' "$LOG_PREFIX" "$*" >&2
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

append_once() {
  local file="$1"
  local marker="$2"
  local content="$3"

  touch "$file"
  if grep -Fq "$marker" "$file"; then
    log "Config ja presente em $file: $marker"
    return
  fi

  {
    printf '\n%s\n' "$marker"
    printf '%s\n' "$content"
  } >> "$file"
  log "Config adicionada em $file: $marker"
}

require_sudo() {
  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    die "Execute sem sudo: ./install.sh. O script vai pedir sudo apenas nas etapas de sistema."
  fi

  if ! command_exists sudo; then
    die "sudo nao encontrado. Execute como root ou instale sudo."
  fi

  log "Validando permissao sudo"
  sudo -v
}

configure_passwordless_sudo() {
  local sudoers_file="/etc/sudoers.d/010-${USER}-nopasswd"
  local sudoers_rule="${USER} ALL=(ALL) NOPASSWD:ALL"

  if [[ ! "$USER" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then
    die "Nome de usuario invalido para sudoers: $USER"
  fi

  if sudo test -f "$sudoers_file" && sudo grep -Fxq "$sudoers_rule" "$sudoers_file"; then
    log "sudo sem senha ja configurado para $USER"
    return
  fi

  log "Configurando sudo sem senha para $USER"
  printf '%s\n' "$sudoers_rule" | sudo tee "$sudoers_file" >/dev/null
  sudo chmod 0440 "$sudoers_file"
  if ! sudo visudo -cf "$sudoers_file" >/dev/null; then
    sudo rm -f "$sudoers_file"
    die "Regra sudoers invalida; arquivo removido"
  fi
}

detect_os() {
  if [[ ! -r /etc/os-release ]]; then
    die "Nao consegui detectar o sistema. Este instalador suporta Ubuntu/Debian."
  fi

  # shellcheck disable=SC1091
  . /etc/os-release
  OS_ID="${ID:-}"
  OS_CODENAME="${VERSION_CODENAME:-}"

  case "$OS_ID" in
    ubuntu|debian) ;;
    *) die "Sistema '$OS_ID' nao suportado. Use Ubuntu ou Debian." ;;
  esac

  if [[ -z "$OS_CODENAME" ]]; then
    OS_CODENAME="$(lsb_release -cs 2>/dev/null || true)"
  fi
  [[ -n "$OS_CODENAME" ]] || die "Nao consegui detectar o codename da distro."

  log "Sistema detectado: $OS_ID $OS_CODENAME"
}

apt_install() {
  local missing=()
  local pkg

  for pkg in "$@"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
      missing+=("$pkg")
    fi
  done

  if [[ "${#missing[@]}" -eq 0 ]]; then
    log "Pacotes apt ja instalados: $*"
    return
  fi

  log "Instalando pacotes apt: ${missing[*]}"
  sudo apt-get install -y "${missing[@]}"
}

ensure_apt_updated() {
  if [[ "${APT_UPDATED:-0}" -eq 1 ]]; then
    return
  fi

  log "Atualizando indices do apt"
  sudo apt-get update
  APT_UPDATED=1
}

install_base_packages() {
  ensure_apt_updated
  apt_install \
    apt-transport-https \
    bat \
    build-essential \
    ca-certificates \
    curl \
    git \
    gh \
    gnupg \
    lsb-release \
    neovim \
    unzip \
    xclip \
    zip \
    zsh
}

install_git_config() {
  if ! git config --global user.name >/dev/null; then
    git config --global user.name "Eli Junior"
    log "Git user.name configurado"
  else
    log "Git user.name ja configurado: $(git config --global user.name)"
  fi

  if ! git config --global user.email >/dev/null; then
    git config --global user.email "elijunior.py@gmail.com"
    log "Git user.email configurado"
  else
    log "Git user.email ja configurado: $(git config --global user.email)"
  fi
}

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log "oh-my-zsh ja instalado"
  else
    log "Instalando oh-my-zsh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  local zshrc="$HOME/.zshrc"
  local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  if [[ ! -d "$zsh_custom/themes/spaceship-prompt" ]]; then
    log "Instalando tema Spaceship"
    git clone --depth=1 https://github.com/spaceship-prompt/spaceship-prompt.git "$zsh_custom/themes/spaceship-prompt"
  else
    log "Tema Spaceship ja instalado"
  fi

  if [[ ! -e "$zsh_custom/themes/spaceship.zsh-theme" ]]; then
    ln -s "$zsh_custom/themes/spaceship-prompt/spaceship.zsh-theme" "$zsh_custom/themes/spaceship.zsh-theme"
    log "Symlink do tema Spaceship criado"
  fi

  if [[ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]]; then
    log "Instalando plugin zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions"
  else
    log "Plugin zsh-autosuggestions ja instalado"
  fi

  if [[ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]]; then
    log "Instalando plugin zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom/plugins/zsh-syntax-highlighting"
  else
    log "Plugin zsh-syntax-highlighting ja instalado"
  fi

  touch "$zshrc"
  if grep -Eq '^ZSH_THEME=' "$zshrc"; then
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="spaceship"/' "$zshrc"
  else
    printf '\nZSH_THEME="spaceship"\n' >> "$zshrc"
  fi

  if grep -Eq '^plugins=' "$zshrc"; then
    sed -i 's/^plugins=.*/plugins=(git z zsh-autosuggestions zsh-syntax-highlighting)/' "$zshrc"
  else
    printf '\nplugins=(git z zsh-autosuggestions zsh-syntax-highlighting)\n' >> "$zshrc"
  fi
  log "Tema e plugins do zsh configurados"

  if grep -Fq 'oh-my-zsh.sh' "$zshrc"; then
    log "Inicializacao do oh-my-zsh ja presente em $zshrc"
  else
    append_once "$zshrc" "# >>> oh-my-zsh init >>>" 'export ZSH="$HOME/.oh-my-zsh"
[[ -s "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"'
  fi

  if grep -Fq "bindkey '^I' menu-select" "$zshrc"; then
    sed -i "s/bindkey '\\^I' menu-select/bindkey '\\^I' expand-or-complete/" "$zshrc"
    log "Bind de Tab corrigido para expand-or-complete"
  fi

  local current_shell
  current_shell="$(getent passwd "$USER" | cut -d: -f7 || true)"
  if [[ "$current_shell" != "$(command -v zsh)" ]]; then
    log "Alterando shell padrao para zsh"
    chsh -s "$(command -v zsh)" "$USER" || warn "Nao foi possivel alterar o shell automaticamente"
  else
    log "zsh ja e o shell padrao"
  fi
}

install_uv() {
  if command_exists uv; then
    log "uv ja instalado: $(uv --version)"
    return
  fi

  log "Instalando uv"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  append_once "$HOME/.zshrc" "# >>> uv init >>>" '. "$HOME/.local/bin/env"'
}

install_sdkman_and_jvm_tools() {
  if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    log "SDKMAN ja instalado"
  else
    log "Instalando SDKMAN"
    curl -s "https://get.sdkman.io" | bash
  fi

  set +u
  # shellcheck disable=SC1091
  source "$HOME/.sdkman/bin/sdkman-init.sh"
  set -u

  if command_exists java; then
    log "Java ja disponivel: $(java -version 2>&1 | head -n 1)"
  else
    log "Instalando Java via SDKMAN"
    SDKMAN_AUTO_ANSWER=true sdk install java
  fi

  if command_exists mvn; then
    log "Maven ja instalado: $(mvn -version | head -n 1)"
  else
    log "Instalando Maven via SDKMAN"
    SDKMAN_AUTO_ANSWER=true sdk install maven
  fi

  append_once "$HOME/.zshrc" "# >>> sdkman init >>>" 'export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"'
}

install_nvm_node() {
  if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    log "nvm ja instalado"
  else
    log "Instalando nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  fi

  export NVM_DIR="$HOME/.nvm"
  set +u
  # shellcheck disable=SC1091
  source "$NVM_DIR/nvm.sh"
  set -u

  if command_exists node; then
    log "Node ja instalado: $(node --version)"
  else
    log "Instalando Node LTS via nvm"
    nvm install --lts
    nvm alias default 'lts/*'
  fi
}

install_docker() {
  local docker_already_installed=0

  if command_exists docker; then
    log "Docker ja instalado: $(docker --version)"
    if docker compose version >/dev/null 2>&1; then
      log "Docker Compose plugin ja instalado: $(docker compose version)"
      return
    else
      log "Docker Compose plugin nao encontrado; vou instalar"
      docker_already_installed=1
    fi
  fi

  if [[ "$docker_already_installed" -eq 0 ]]; then
    log "Removendo pacotes Docker antigos, se existirem"
    sudo apt-get remove -y docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc || true
  fi

  ensure_apt_updated
  apt_install ca-certificates curl gnupg

  log "Configurando repositorio oficial do Docker"
  sudo install -m 0755 -d /etc/apt/keyrings
  if [[ -f /etc/apt/keyrings/docker.gpg ]]; then
    log "Chave GPG do Docker ja existe"
  else
    curl -fsSL "https://download.docker.com/linux/$OS_ID/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  fi
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  printf 'deb [arch=%s signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/%s %s stable\n' \
    "$(dpkg --print-architecture)" "$OS_ID" "$OS_CODENAME" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  APT_UPDATED=0
  ensure_apt_updated
  if [[ "$docker_already_installed" -eq 1 ]]; then
    apt_install docker-compose-plugin
  else
    apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  fi

  if groups "$USER" | grep -qw docker; then
    log "Usuario $USER ja esta no grupo docker"
  else
    sudo usermod -aG docker "$USER"
    log "Usuario $USER adicionado ao grupo docker. Faca logout/login para aplicar."
  fi
}

configure_aliases() {
  append_once "$HOME/.zshrc" "# >>> generalConfigs aliases >>>" 'if command -v batcat >/dev/null 2>&1; then
  alias cat="batcat --paging=never --color=auto"
elif command -v bat >/dev/null 2>&1; then
  alias cat="bat --paging=never --color=auto"
fi
alias vi=nvim
alias vim=nvim
alias please=sudo
alias gs="git status"
alias gcm="git commit -m"
alias gaa="git add --all"
alias gb="git branch"
alias gps="git push"
alias gp="git pull"'
}

install_fonts() {
  local source_dir
  source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/Fonts"
  local target_dir="$HOME/.local/share/fonts/generalConfigs"

  if [[ ! -d "$source_dir" ]]; then
    log "Diretorio Fonts nao encontrado, pulando fontes"
    return
  fi

  mkdir -p "$target_dir"
  log "Instalando fontes locais em $target_dir"
  find "$source_dir" -type f \( -name '*.ttf' -o -name '*.otf' \) -exec cp -n {} "$target_dir/" \;

  if command_exists fc-cache; then
    fc-cache -f "$target_dir"
    log "Cache de fontes atualizado"
  fi
}

main() {
  log "Inicio da instalacao"
  detect_os
  require_sudo
  configure_passwordless_sudo
  install_base_packages
  install_git_config
  install_oh_my_zsh
  install_uv
  install_sdkman_and_jvm_tools
  install_nvm_node
  install_docker
  configure_aliases
  install_fonts
  log "Instalacao concluida"
  log "Abra um novo terminal para carregar zsh, SDKMAN, nvm, uv e grupo docker."
}

main "$@"
