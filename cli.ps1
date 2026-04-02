param(
    [string]$Command
)

function Show-Menu {
    Clear-Host
    Write-Host "==== CONQUISTA CLI ====" -ForegroundColor Cyan
    Write-Host "1 - Limpar navegadores"
    Write-Host "2 - Abrir URLs da aula"
    Write-Host "0 - Sair"
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
# EXECUÇÃO DIRETA
# =========================
if ($Command) {
    if ($commands.ContainsKey($Command)) {
        Run-Module $commands[$Command]
        exit
    } else {
        Write-Host "Comando inválido: $Command" -ForegroundColor Red
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
