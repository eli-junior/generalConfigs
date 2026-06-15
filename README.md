# generalConfigs

Aqui estão algumas das configurações que faço em um novo ambiente de desenvolvimento.

## Estrutura

- `linux/`: instalador e perfil zsh para Ubuntu/Debian/WSL
- `windows/`: profile PowerShell e configuracao WSL para usar no Windows
- `Fonts/`: fontes compartilhadas usadas pelo setup
- `vscode/`: configuracoes do VS Code

## Uso Linux

Em uma instalação limpa de Ubuntu ou Debian, clone este repositório e execute o instalador:

```bash
git clone <url-do-repositorio> generalConfigs
cd generalConfigs/linux
chmod +x install.sh
./install.sh
```

Execute com o seu usuário normal, sem `sudo`. O script valida o sudo no início e pede senha apenas quando ainda for necessário.

O instalador é idempotente: ele checa o que já existe antes de instalar e loga cada etapa no stdout com o prefixo `[generalConfigs]`.

Ele instala/configura:

- pacotes base de desenvolvimento via `apt`
- `git`, `gh`, `zsh`, `curl`, `xclip`, `bat`, `neovim`
- sudo sem senha para o usuario atual via `/etc/sudoers.d`
- nome e email globais do Git
- oh-my-zsh com tema Spaceship
- plugins `zsh-autosuggestions`, `zsh-syntax-highlighting`, `git` e `z`
- `uv` para Python
- SDKMAN, Java e Maven (`mvn`)
- nvm e Node LTS
- Docker Engine e plugin `docker compose`
- aliases principais no `~/.zshrc`
- fontes locais do diretório `Fonts`

## Uso Windows

O profile PowerShell fica em `windows/Microsoft.PowerShell_profile.ps1`.

A configuracao WSL fica em `windows/.wslconfig`.

## Observações

- O script suporta Ubuntu e Debian.
- A regra de sudo sem senha é criada em `/etc/sudoers.d/010-$USER-nopasswd` e validada com `visudo`.
- Ao final, abra um novo terminal para carregar zsh, SDKMAN, nvm, uv e aliases.
- Para aplicar a entrada no grupo `docker`, faça logout/login ou reinicie a sessão.
