# Abre os links da aula de uma turma.
# Os links ficam em data/turmas/<turma>.json (formato em docs/Dados.md).
#
# Uso:
#   & ([scriptblock]::Create((irm <url>/modules/open.ps1))) -Turma 1ano
#   & ([scriptblock]::Create((irm <url>/modules/open.ps1))) -Turma 1ano -Data 2026-11-17
#   irm <url>/modules/open.ps1 | iex      # pergunta a turma
#
# Teste local, sem precisar de push: defina $env:IRM_DADOS com o caminho da pasta data\turmas.
#
# Ao abrir os links com sucesso, marca $global:IRM_AmbientePronto = $true
# (o cli.ps1 usa isso para fechar o PowerShell).
param(
    [string]$Turma,
    [string]$Data
)

$fonte = "https://raw.githubusercontent.com/petersonros/irm/main/data/turmas"

# =========================
# DADOS
# =========================
function Get-DadosTurma {
    param ($id)

    if ($env:IRM_DADOS) {
        $path = Join-Path $env:IRM_DADOS "$id.json"
        return (Get-Content -LiteralPath $path -Raw -Encoding UTF8 -ErrorAction Stop | ConvertFrom-Json)
    }

    # O raw do GitHub serve .json como text/plain: chega como texto e precisa ser convertido
    $resp = Invoke-RestMethod -Uri "$fonte/$id.json" -UseBasicParsing
    if ($resp -is [string]) { $resp = $resp | ConvertFrom-Json }
    return $resp
}

function Format-Aula {
    param ($aula)

    if ($aula.data) {
        $texto = ([datetime]::ParseExact($aula.data, 'yyyy-MM-dd', $null)).ToString('dd-MM-yyyy')
    } else {
        $texto = "sem data"
    }

    if ($aula.professora -and $aula.sala) { $texto += " — $($aula.professora) ($($aula.sala))" }
    elseif ($aula.professora)             { $texto += " — $($aula.professora)" }
    elseif ($aula.sala)                   { $texto += " — $($aula.sala)" }

    $ativos = @($aula.links | Where-Object { $_.ativo -ne $false }).Count
    $texto += " · $ativos link" + $(if ($ativos -ne 1) { "s" } else { "" })
    if ($aula.obs) { $texto += " · $($aula.obs)" }
    return $texto
}

# Menu de escolha quando não dá para decidir pela data. Devolve a aula ou $null (voltar).
function Select-Aula {
    param ($titulo, $opcoes)

    while ($true) {
        Clear-Host
        Write-Host ""
        Write-Host "  ==== $($dados.nome) ====" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  $titulo" -ForegroundColor Yellow
        Write-Host ""
        for ($i = 0; $i -lt $opcoes.Count; $i++) {
            Write-Host ("  [{0}]" -f ($i + 1)) -ForegroundColor Green -NoNewline
            Write-Host (" {0}" -f (Format-Aula $opcoes[$i]))
        }
        Write-Host ""
        Write-Host "  [V]" -ForegroundColor DarkGray -NoNewline; Write-Host " Voltar"
        Write-Host ""

        $choice = (Read-Host "  Escolha").Trim()
        if ($choice -match '^[Vv]$') { return $null }
        if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $opcoes.Count) {
            return $opcoes[[int]$choice - 1]
        }
    }
}

# =========================
# NAVEGADOR
# =========================
$browser = $null
$processName = $null
if (Get-Command chrome.exe -ErrorAction SilentlyContinue) {
    $browser = "chrome.exe"
    $processName = "chrome"
}
elseif (Get-Command msedge.exe -ErrorAction SilentlyContinue) {
    $browser = "msedge.exe"
    $processName = "msedge"
}

# Abre uma única URL em nova aba (no navegador já aberto, se houver)
function Open-SingleUrl {
    param ($url)

    if ($browser) {
        Start-Process $browser ("`"" + $url + "`"")
    } else {
        Start-Process $url
    }
}

# Fecha o navegador e abre todas na mesma janela, em ordem
function Open-AllUrls {
    param ($links)

    if (-not $browser) {
        foreach ($link in $links) {
            Start-Process $link.Url
            Start-Sleep -Milliseconds 800
        }
        return
    }

    # Encerrar o navegador se já estiver aberto (garante --new-window limpo)
    if (Get-Process -Name $processName -ErrorAction SilentlyContinue) {
        Write-Host "   Navegador aberto detectado — encerrando antes de abrir..." -ForegroundColor DarkYellow
        Stop-Process -Name $processName -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }

    Start-Process $browser ("--new-window `"" + $links[0].Url + "`"")
    Start-Sleep -Seconds 2
    foreach ($link in ($links | Select-Object -Skip 1)) {
        Start-Process $browser ("`"" + $link.Url + "`"")
        Start-Sleep -Milliseconds 800
    }
}

# Submenu para abrir um por um (modo "menu")
function Show-LinksMenu {
    param ($titulo, $links)

    while ($true) {
        Clear-Host
        Write-Host ""
        Write-Host "  ==== $titulo ====" -ForegroundColor Cyan
        Write-Host ""
        for ($i = 0; $i -lt $links.Count; $i++) {
            $mark  = if ($links[$i].Opened) { "✓" } else { " " }
            $color = if ($links[$i].Opened) { "DarkGray" } else { "White" }
            Write-Host ("  [{0}]" -f ($i + 1)) -ForegroundColor Green -NoNewline
            Write-Host (" {0} {1}" -f $mark, $links[$i].Label) -ForegroundColor $color
        }
        Write-Host ""
        Write-Host "  [Enter]" -ForegroundColor Cyan -NoNewline; Write-Host " Abrir o próximo da lista"
        Write-Host "  [T]" -ForegroundColor Cyan -NoNewline; Write-Host " Abrir todos de uma vez"
        Write-Host "  [V]" -ForegroundColor DarkGray -NoNewline; Write-Host " Voltar"
        Write-Host ""

        $choice = (Read-Host "  Escolha").Trim()

        if ($choice -eq "") {
            $next = $links | Where-Object { -not $_.Opened } | Select-Object -First 1
            if ($next) {
                Write-Host "🚀 Abrindo: $($next.Label)" -ForegroundColor Cyan
                Open-SingleUrl $next.Url
                $next.Opened = $true
            } else {
                Write-Host "Todos os links já foram abertos." -ForegroundColor Yellow
                Start-Sleep -Seconds 1
            }
        }
        elseif ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $links.Count) {
            $link = $links[[int]$choice - 1]
            Write-Host "🚀 Abrindo: $($link.Label)" -ForegroundColor Cyan
            Open-SingleUrl $link.Url
            $link.Opened = $true
        }
        elseif ($choice -match '^[Tt]$') {
            Write-Host "🚀 Abrindo todos os links..." -ForegroundColor Cyan
            Open-AllUrls $links
            Write-Host "✅ Ambiente pronto!"
            $global:IRM_AmbientePronto = $true
            break
        }
        elseif ($choice -match '^[Vv]$') {
            break
        }
    }
}

# =========================
# FLUXO
# =========================
if (-not $Turma) {
    $Turma = (Read-Host "  Turma (ex.: 1ano, inf4, pesquisa)").Trim().ToLower()
    if (-not $Turma) { return }
}

try {
    $dados = Get-DadosTurma $Turma
    if (-not $dados -or -not $dados.nome) { throw "Arquivo vazio ou fora do formato (ver docs/Dados.md)." }
} catch {
    Write-Host ""
    Write-Host "Não foi possível carregar a turma '$Turma'." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    return
}

$aulas = @($dados.aulas)
if ($aulas.Count -eq 0) {
    Write-Host "Nenhuma aula cadastrada para $($dados.nome)." -ForegroundColor Yellow
    return
}

$hoje = if ($Data) { $Data } else { Get-Date -Format 'yyyy-MM-dd' }
$doDia = @($aulas | Where-Object { $_.data -eq $hoje })

if ($doDia.Count -eq 1) {
    $aula = $doDia[0]
} elseif ($doDia.Count -gt 1) {
    $aula = Select-Aula "Há $($doDia.Count) aulas hoje. Qual abrir?" $doDia
} else {
    $aula = Select-Aula "Nenhuma aula cadastrada para hoje. Últimas aulas:" @($aulas | Select-Object -First 10)
}
if (-not $aula) { return }

$links = @(foreach ($l in $aula.links) {
    if ($l.ativo -ne $false) {
        $label = if ($l.label) { $l.label } else { $l.url }
        [PSCustomObject]@{ Label = $label; Url = $l.url; Opened = $false }
    }
})
if ($links.Count -eq 0) {
    Write-Host "Essa aula não tem links ativos." -ForegroundColor Yellow
    return
}

if ($dados.modo -eq "menu") {
    Show-LinksMenu $dados.nome $links
} else {
    Write-Host "🚀 Abrindo $($dados.nome): $(Format-Aula $aula)" -ForegroundColor Cyan
    Open-AllUrls $links
    Write-Host "✅ Ambiente pronto!"
    $global:IRM_AmbientePronto = $true
}
