# ==============================
# PowerShell Profile - Eli
# Oh My Posh + qualidade de vida
# ==============================

# Limpa a tela ao abrir
Clear-Host

# Encoding melhor para terminal moderno
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Oh My Posh
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    # Troque o tema aqui se quiser
    # Veja temas com: Get-PoshThemes
    $theme = "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json"

    if (Test-Path $theme) {
        oh-my-posh init pwsh --config $theme | Invoke-Expression
    } else {
        oh-my-posh init pwsh | Invoke-Expression
    }
} else {
    Write-Host "oh-my-posh nao encontrado. Instale com: winget install JanDeDobbeleer.OhMyPosh" -ForegroundColor Yellow
}

# PSReadLine: autocomplete e historico melhorado
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine

    $psReadLineOptions = (Get-Command Set-PSReadLineOption).Parameters

    if ($psReadLineOptions.ContainsKey("PredictionSource")) {
        Set-PSReadLineOption -PredictionSource History
    }

    if ($psReadLineOptions.ContainsKey("PredictionViewStyle")) {
        Set-PSReadLineOption -PredictionViewStyle ListView
    }

    Set-PSReadLineOption -EditMode Windows

    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteChar
    Set-PSReadLineKeyHandler -Key Ctrl+z -Function Undo
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# Terminal Icons, se estiver instalado
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons
}

# Chocolatey autocomplete
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if ($env:ChocolateyInstall -and (Test-Path $ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

# Aliases uteis
Set-Alias ll Get-ChildItem
Set-Alias g git
Set-Alias c cls

function la {
    Get-ChildItem -Force
}

function .. {
    Set-Location ..
}

function ... {
    Set-Location ..\..
}

function home {
    Set-Location $HOME
}

function docs {
    Set-Location "$HOME\Documents"
}

function reload-profile {
    . $PROFILE
    Write-Host "Profile recarregado." -ForegroundColor Green
}

function edit-profile {
    code $PROFILE
}

# Mostra onde esta um comando especifico
function which {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    Get-Command $Command -ErrorAction SilentlyContinue |
        Select-Object CommandType, Name, Source
}

# Lista comandos disponiveis, com filtro opcional
function commands {
    param(
        [string]$Filter = "*"
    )

    Get-Command $Filter |
        Sort-Object CommandType, Name |
        Select-Object CommandType, Name, Source
}

# Versao formatada em tabela para explorar comandos
function cmds {
    param(
        [string]$Filter = "*"
    )

    Get-Command $Filter |
        Sort-Object CommandType, Name |
        Format-Table CommandType, Name, Source -AutoSize
}

function mkcd {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
}

function touch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (Test-Path $Path) {
        (Get-Item $Path).LastWriteTime = Get-Date
    } else {
        New-Item -ItemType File -Path $Path | Out-Null
    }
}

# Git helpers
function gs {
    git status
}

function ga {
    git add .
}

function gcmsg {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    git commit -m "$Message"
}

function gp {
    git push
}

function gl {
    git log --oneline --graph --decorate -n 15
}

# Info inicial discreta
Write-Host ""
Write-Host "PowerShell pronto, Eli." -ForegroundColor Cyan
Write-Host "Perfil: $PROFILE" -ForegroundColor DarkGray
