param(
    [string]$Command,
    [switch]$Help
)

function Show-Menu {
    Clear-Host
    Write-Host ""
    Write-Host "  ==== CONQUISTA CLI ====" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [4]" -ForegroundColor Cyan -NoNewline; Write-Host " Abrir URLs — Infantil 4"
    Write-Host "  [5]" -ForegroundColor Cyan -NoNewline; Write-Host " Abrir URLs — Infantil 5"
    Write-Host "  [1]" -ForegroundColor Cyan -NoNewline; Write-Host " Abrir URLs — 1º ano"
    Write-Host "  [2]" -ForegroundColor Cyan -NoNewline; Write-Host " Abrir URLs — 2º ano"
    Write-Host "  [3]" -ForegroundColor Cyan -NoNewline; Write-Host " Abrir URLs — 3º ano"
    Write-Host "  [7]" -ForegroundColor Cyan -NoNewline; Write-Host " Abrir URLs — 4º ano"
    Write-Host "  [8]" -ForegroundColor Cyan -NoNewline; Write-Host " Abrir URLs — 5º ano"
    Write-Host ""
    Write-Host "  [6]" -ForegroundColor Green -NoNewline; Write-Host " Pesquisa de satisfação"
    Write-Host ""
    Write-Host "  [0]" -ForegroundColor Red -NoNewline; Write-Host " Limpar navegadores"
    Write-Host "  [W]" -ForegroundColor Blue -NoNewline; Write-Host " Aplicar papel de parede"
    Write-Host "  [9]" -ForegroundColor DarkGray -NoNewline; Write-Host " Sair"
    Write-Host ""
}

function Show-Help {
    Write-Host ""
    Write-Host "==== CONQUISTA CLI — Ajuda ====" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Uso:" -ForegroundColor Yellow
    Write-Host "  irm <url>/cli.ps1 | iex                  # menu interativo"
    Write-Host "  irm <url>/cli.ps1 -Command <nome> | iex  # execução direta"
    Write-Host "  irm <url>/cli.ps1 -Help | iex            # esta ajuda"
    Write-Host ""
    Write-Host "Comandos disponíveis:" -ForegroundColor Yellow
    Write-Host "  clean    Fecha Chrome/Edge e remove histórico, cookies, cache, senhas e autofill"
    Write-Host "  open           Pergunta a turma e abre a aula do dia"
    Write-Host "  open-1ano      Abre a aula do dia do 1º ano   (antigo open-i1)"
    Write-Host "  open-2ano      Abre a aula do dia do 2º ano   (antigo open-i2)"
    Write-Host "  open-3ano      Abre a aula do dia do 3º ano   (antigo open-i3)"
    Write-Host "  open-4ano      Abre a aula do dia do 4º ano"
    Write-Host "  open-5ano      Abre a aula do dia do 5º ano"
    Write-Host "  open-inf4      Abre a aula do dia do Infantil 4 (antigo open-i4)"
    Write-Host "  open-inf5      Abre a aula do dia do Infantil 5 (antigo open-i5)"
    Write-Host "  open-pesquisa  Pesquisa de satisfação"
    Write-Host "  wallpaper Escolhe e aplica um papel de parede da coleção"
    Write-Host ""
    Write-Host "Exemplos:" -ForegroundColor Yellow
    Write-Host "  ... -Command clean"
    Write-Host "  ... -Command open"
    Write-Host "  ... -Command open-1ano"
    Write-Host ""
}

function Run-Module {
    param ($url, $Turma)

    try {
        if ($Turma) {
            # irm | iex não repassa parâmetros: monta um scriptblock para passar -Turma
            & ([scriptblock]::Create((Invoke-RestMethod $url))) -Turma $Turma
        } else {
            Invoke-RestMethod $url | Invoke-Expression
        }
    } catch {
    Write-Host ""
    Write-Host "Erro ao executar módulo:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}
}

# URLs dos módulos (RAW do GitHub)
$base = "https://raw.githubusercontent.com/petersonros/irm/main/modules"

$commands = @{
    "clean"     = "$base/clean.ps1"
    "open"      = "$base/open.ps1"
    "wallpaper" = "$base/wallpaper.ps1"
}

# Turmas: todas usam o open.ps1, que lê data/turmas/<turma>.json
$turmas = @{
    "open-1ano"     = "1ano"
    "open-2ano"     = "2ano"
    "open-3ano"     = "3ano"
    "open-4ano"     = "4ano"
    "open-5ano"     = "5ano"
    "open-inf4"     = "inf4"
    "open-inf5"     = "inf5"
    "open-pesquisa" = "pesquisa"
    # nomes antigos, mantidos por compatibilidade
    "open-i1"       = "1ano"
    "open-i2"       = "2ano"
    "open-i3"       = "3ano"
    "open-i4"       = "inf4"
    "open-i5"       = "inf5"
}

# =========================
# AJUDA
# =========================
if ($Help) {
    Show-Help
    exit
}

# =========================
# EXECUÇÃO DIRETA
# =========================
if ($Command) {
    if ($turmas.ContainsKey($Command)) {
        Run-Module $commands["open"] $turmas[$Command]
        exit
    } elseif ($commands.ContainsKey($Command)) {
        Run-Module $commands[$Command]
        exit
    } else {
        Write-Host "Comando inválido: $Command" -ForegroundColor Red
        Write-Host "Use -Help para ver os comandos disponíveis." -ForegroundColor DarkYellow
        exit
    }
}

# =========================
# MODO INTERATIVO
# =========================
do {
    Show-Menu
    $op = Read-Host "  Escolha"

    switch ($op) {
        "1" { Run-Module $commands["open"] "1ano" }
        "2" { Run-Module $commands["open"] "2ano" }
        "3" { Run-Module $commands["open"] "3ano" }
        "4" { Run-Module $commands["open"] "inf4" }
        "5" { Run-Module $commands["open"] "inf5" }
        "6" { Run-Module $commands["open"] "pesquisa" }
        "7" { Run-Module $commands["open"] "4ano" }
        "8" { Run-Module $commands["open"] "5ano" }
        "0" { Run-Module $commands["clean"] }
        "w" { Run-Module $commands["wallpaper"] }
    }

    if ($op -ne "9") { Pause }
} while ($op -ne "9")