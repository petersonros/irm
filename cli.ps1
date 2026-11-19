param(
    [string]$Command,
    [switch]$Help
)

# URLs dos módulos (RAW do GitHub)
$base = "https://raw.githubusercontent.com/petersonros/irm/main/modules"

$commands = @{
    "clean"     = "$base/clean.ps1"
    "open"      = "$base/open.ps1"
    "wallpaper" = "$base/wallpaper.ps1"
}

# Turmas, na ordem do menu. Cada uma lê data/turmas/<Id>.json pelo open.ps1.
# Para incluir uma turma: crie o JSON e acrescente uma linha aqui (o número do menu sai da posição).
$turmas = @(
    [PSCustomObject]@{ Id = "inf4"; Nome = "Infantil 4" }
    [PSCustomObject]@{ Id = "inf5"; Nome = "Infantil 5" }
    [PSCustomObject]@{ Id = "1ano"; Nome = "1º ano" }
    [PSCustomObject]@{ Id = "2ano"; Nome = "2º ano" }
    [PSCustomObject]@{ Id = "3ano"; Nome = "3º ano" }
    [PSCustomObject]@{ Id = "4ano"; Nome = "4º ano" }
    [PSCustomObject]@{ Id = "5ano"; Nome = "5º ano" }
)
$pesquisa = [PSCustomObject]@{ Id = "pesquisa"; Nome = "Pesquisa de satisfação" }

# Nomes antigos de -Command, mantidos por compatibilidade
$aliases = @{
    "open-i1" = "1ano"; "open-i2" = "2ano"; "open-i3" = "3ano"
    "open-i4" = "inf4"; "open-i5" = "inf5"
}

function Show-Menu {
    Clear-Host
    Write-Host ""
    Write-Host "  ==== CONQUISTA CLI ====" -ForegroundColor Cyan
    Write-Host ("  Hoje: {0}" -f (Get-Date -Format 'dd-MM-yyyy')) -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Aula do dia" -ForegroundColor Yellow
    for ($i = 0; $i -lt $turmas.Count; $i++) {
        Write-Host ("  [{0}]" -f ($i + 1)) -ForegroundColor Cyan -NoNewline; Write-Host " $($turmas[$i].Nome)"
    }
    Write-Host ""
    Write-Host "  Outros" -ForegroundColor Yellow
    Write-Host ("  [{0}]" -f ($turmas.Count + 1)) -ForegroundColor Green -NoNewline; Write-Host " $($pesquisa.Nome)"
    Write-Host "  [0]" -ForegroundColor Red -NoNewline; Write-Host " Limpar navegadores"
    Write-Host "  [W]" -ForegroundColor Blue -NoNewline; Write-Host " Papel de parede"
    Write-Host "  [S]" -ForegroundColor DarkGray -NoNewline; Write-Host " Sair"
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
    Write-Host "  clean          Fecha Chrome/Edge e remove histórico, cookies, cache, senhas e autofill"
    Write-Host "  wallpaper      Escolhe e aplica um papel de parede da coleção"
    Write-Host "  open           Pergunta a turma e abre a aula do dia"
    foreach ($t in ($turmas + $pesquisa)) {
        Write-Host ("  {0,-14} {1}" -f "open-$($t.Id)", $t.Nome)
    }
    Write-Host ""
    Write-Host "Exemplos:" -ForegroundColor Yellow
    Write-Host "  ... -Command clean"
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

# Abre a aula da turma. Se os links abriram, fecha o PowerShell.
function Open-Turma {
    param ($id)

    $global:IRM_AmbientePronto = $false   # o open.ps1 marca $true quando abre os links
    Run-Module $commands["open"] $id
    if ($global:IRM_AmbientePronto) {
        Write-Host "   Fechando o PowerShell..." -ForegroundColor DarkGray
        Start-Sleep -Seconds 2
        [Environment]::Exit(0)
    }
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
    $id = $null
    if ($Command -like "open-*") {
        $sufixo = $Command.Substring(5)
        if ($aliases.ContainsKey($Command)) { $id = $aliases[$Command] }
        elseif (($turmas + $pesquisa) | Where-Object { $_.Id -eq $sufixo }) { $id = $sufixo }
    }

    if ($id) {
        Open-Turma $id
    } elseif ($commands.ContainsKey($Command)) {
        Run-Module $commands[$Command]
    } else {
        Write-Host "Comando inválido: $Command" -ForegroundColor Red
        Write-Host "Use -Help para ver os comandos disponíveis." -ForegroundColor DarkYellow
    }
    exit
}

# =========================
# MODO INTERATIVO
# =========================
while ($true) {
    Show-Menu
    $op = (Read-Host "  Escolha").Trim()

    if ($op -match '^[Ss]$') { break }

    if ($op -match '^\d+$' -and [int]$op -ge 1 -and [int]$op -le $turmas.Count) {
        Open-Turma $turmas[[int]$op - 1].Id
    }
    elseif ($op -eq [string]($turmas.Count + 1)) { Open-Turma $pesquisa.Id }
    elseif ($op -eq "0")      { Run-Module $commands["clean"] }
    elseif ($op -match '^[Ww]$') { Run-Module $commands["wallpaper"] }
    else { continue }

    Pause
}
