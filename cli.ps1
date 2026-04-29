param(
    [string]$Command,
    [switch]$Help
)

function Show-Menu {
    Clear-Host
    Write-Host "==== CONQUISTA CLI ====" -ForegroundColor Cyan
    Write-Host "1 - Limpar navegadores"
    Write-Host "2 - Abrir URLs da aula (genérico)"
    Write-Host "3 - Abrir URLs — Infantil 1"
    Write-Host "4 - Abrir URLs — Infantil 2"
    Write-Host "5 - Abrir URLs — Infantil 3"
    Write-Host "6 - Abrir URLs — Infantil 4"
    Write-Host "7 - Abrir URLs — Infantil 5"
    Write-Host "0 - Sair"
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
    Write-Host "  open     Abre as URLs da aula no Chrome (ou Edge) em uma janela nova"
    Write-Host "  open-i1  Abre as URLs do Infantil 1"
    Write-Host "  open-i2  Abre as URLs do Infantil 2"
    Write-Host "  open-i3  Abre as URLs do Infantil 3"
    Write-Host "  open-i4  Abre as URLs do Infantil 4"
    Write-Host "  open-i5  Abre as URLs do Infantil 5"
    Write-Host ""
    Write-Host "Exemplos:" -ForegroundColor Yellow
    Write-Host "  ... -Command clean"
    Write-Host "  ... -Command open"
    Write-Host "  ... -Command open-i1"
    Write-Host ""
}

function Run-Module {
    param ($url)

    try {
        irm $url | iex
    } catch {
        Write-Host "Erro ao executar módulo" -ForegroundColor Red
    }
}

# URLs dos módulos (RAW do GitHub)
$base = "https://raw.githubusercontent.com/petersonros/irm/main/modules"

$commands = @{
    "clean"   = "$base/clean.ps1"
    "open"    = "$base/open.ps1"
    "open-i1" = "$base/open-inf1.ps1"
    "open-i2" = "$base/open-inf2.ps1"
    "open-i3" = "$base/open-inf3.ps1"
    "open-i4" = "$base/open-inf4.ps1"
    "open-i5" = "$base/open-inf5.ps1"
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
    if ($commands.ContainsKey($Command)) {
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
    $op = Read-Host "Escolha"

    switch ($op) {
        "1" { Run-Module $commands["clean"] }
        "2" { Run-Module $commands["open"] }
        "3" { Run-Module $commands["open-i1"] }
        "4" { Run-Module $commands["open-i2"] }
        "5" { Run-Module $commands["open-i3"] }
        "6" { Run-Module $commands["open-i4"] }
        "7" { Run-Module $commands["open-i5"] }
    }

    Pause
} while ($op -ne "0")
