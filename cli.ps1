param(
    [string]$Command,
    [switch]$Help
)

function Show-Menu {
    Clear-Host
    Write-Host "==== CONQUISTA CLI ====" -ForegroundColor Cyan
    Write-Host "1 - Limpar navegadores"
    Write-Host "2 - Abrir URLs da aula"
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
    Write-Host "  clean   Fecha Chrome/Edge e remove histórico, cookies, cache, senhas e autofill"
    Write-Host "  open    Abre as URLs da aula no Chrome (ou Edge) em uma janela nova"
    Write-Host ""
    Write-Host "Exemplos:" -ForegroundColor Yellow
    Write-Host "  ... -Command clean"
    Write-Host "  ... -Command open"
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
    "clean" = "$base/clean.ps1"
    "open"  = "$base/open.ps1"
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
    }

    Pause
} while ($op -ne "0")
