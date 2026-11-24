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

function Get-NomeProfessora {
    param ($aula)

    if (-not $aula.professora) { return "Sem professora" }
    return $aula.professora
}

# Uma opção por professora + sala, na ordem em que aparecem
function Get-Professoras {
    param ($lista)

    $vistos = @{}
    foreach ($a in $lista) {
        $nome = Get-NomeProfessora $a
        $chave = "$nome|$($a.sala)"
        if ($vistos.ContainsKey($chave)) { continue }
        $vistos[$chave] = $true
        $rotulo = $nome
        if ($a.sala) { $rotulo += " ($($a.sala))" }
        [PSCustomObject]@{
            Rotulo = $rotulo
            Aulas  = @($lista | Where-Object { (Get-NomeProfessora $_) -eq $nome -and "$($_.sala)" -eq "$($a.sala)" })
        }
    }
}

# Menu numerado. Devolve o índice escolhido, a letra de um dos extras ou "V".
# $extras: lista de @("Letra", "texto"). "Enter" também é aceito como letra.
function Read-Opcao {
    param ($titulo, $textos, $extras)

    $textos = @($textos)
    while ($true) {
        Clear-Host
        Write-Host ""
        Write-Host "  ==== $($dados.nome) ====" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  $titulo" -ForegroundColor Yellow
        Write-Host ""
        for ($i = 0; $i -lt $textos.Count; $i++) {
            Write-Host ("  [{0}]" -f ($i + 1)) -ForegroundColor Green -NoNewline
            Write-Host " $($textos[$i])"
        }
        Write-Host ""
        foreach ($e in $extras) {
            Write-Host "  [$($e[0])]" -ForegroundColor Cyan -NoNewline; Write-Host " $($e[1])"
        }
        Write-Host "  [V]" -ForegroundColor DarkGray -NoNewline; Write-Host " Voltar"
        Write-Host ""

        $choice = (Read-Host "  Escolha").Trim().ToUpper()
        if ($choice -eq "V") { return "V" }
        if ($choice -match '^\d{1,4}$' -and [int]$choice -ge 1 -and [int]$choice -le $textos.Count) {
            return ([int]$choice - 1)
        }
        if ($choice -eq "") { $choice = "ENTER" }
        foreach ($e in $extras) {
            if ($choice -eq $e[0].ToUpper()) { return $e[0] }
        }
    }
}

# Aulas do dia. Com mais de uma, pergunta a professora (e depois a aula, se ela tiver mais de uma).
# Devolve a aula, "O" (outras aulas) ou "V".
function Select-AulaDoDia {
    param ($lista, $temOutras)

    $lista = @($lista)
    $extras = @()
    if ($temOutras) { $extras += , @("O", "Outras aulas (antigas, outra professora, sugestões)") }

    while ($true) {
        if ($lista.Count -eq 1) {
            $r = Read-Opcao "Aula de hoje: $(Format-Aula $lista[0])" @() (@(, @("Enter", "Abrir esta aula")) + $extras)
            if ($r -eq "Enter") { return $lista[0] }
            return $r
        }

        $profs = @(Get-Professoras $lista)
        if ($profs.Count -eq 1) {
            $r = Read-Opcao "Há $($lista.Count) aulas hoje. Qual abrir?" @($lista | ForEach-Object { Format-Aula $_ }) $extras
            if ($r -is [int]) { return $lista[$r] }
            return $r
        }

        $r = Read-Opcao "Há $($lista.Count) aulas hoje. De qual professora?" @($profs | ForEach-Object { $_.Rotulo }) $extras
        if ($r -isnot [int]) { return $r }
        $dela = @($profs[$r].Aulas)
        if ($dela.Count -eq 1) { return $dela[0] }
        $q = Read-Opcao "$($profs[$r].Rotulo): qual aula abrir?" @($dela | ForEach-Object { Format-Aula $_ }) @()
        if ($q -is [int]) { return $dela[$q] }
    }
}

# Todas as aulas, 10 por vez, com filtro por professora. Devolve a aula, "S" (sugestões) ou "V".
function Select-Aula {
    param ($titulo, $lista, $sugestoes)

    $lista = @($lista)
    $profs = @(Get-Professoras $lista)
    $filtro = $null
    $mostrar = 10

    while ($true) {
        $base = $lista
        $cab = $titulo
        if ($filtro) { $base = @($filtro.Aulas); $cab = "Aulas de $($filtro.Rotulo):" }
        $visiveis = @($base | Select-Object -First $mostrar)

        $extras = @()
        if ($base.Count -gt $visiveis.Count) { $extras += , @("M", "Mais antigas (faltam $($base.Count - $visiveis.Count))") }
        if ($filtro)               { $extras += , @("P", "Mostrar todas as professoras") }
        elseif ($profs.Count -gt 1) { $extras += , @("P", "Filtrar por professora") }
        if (@($sugestoes).Count -gt 0) { $extras += , @("S", "Sugestões ainda não usadas ($(@($sugestoes).Count))") }

        $r = Read-Opcao $cab @($visiveis | ForEach-Object { Format-Aula $_ }) $extras
        if ($r -is [int]) { return $visiveis[$r] }
        if ($r -eq "M") { $mostrar += 10; continue }
        if ($r -eq "P") {
            $mostrar = 10
            if ($filtro) { $filtro = $null; continue }
            $q = Read-Opcao "De qual professora?" @($profs | ForEach-Object { $_.Rotulo }) @()
            if ($q -is [int]) { $filtro = $profs[$q] }
            continue
        }
        return $r
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
$global:IRM_AmbientePronto = $false

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

$aulas = @($dados.aulas | Where-Object { $_ })
$sugestoes = @($dados.sugestoes | Where-Object { $_ -and $_.ativo -ne $false } | ForEach-Object {
    $label = if ($_.label) { $_.label } else { $_.url }
    $origem = @()
    if ($_.sugerido)   { $origem += ([datetime]::ParseExact($_.sugerido, 'yyyy-MM-dd', $null)).ToString('dd-MM-yyyy') }
    if ($_.professora) { $origem += $_.professora }
    if ($origem.Count -gt 0) { $label += " · $($origem -join ' · ')" }
    [PSCustomObject]@{ Label = $label; Url = $_.url; Opened = $false }
})
if ($aulas.Count -eq 0 -and $sugestoes.Count -eq 0) {
    Write-Host "Nenhuma aula cadastrada para $($dados.nome)." -ForegroundColor Yellow
    return
}

$hoje = if ($Data) { $Data } else { Get-Date -Format 'yyyy-MM-dd' }
$doDia = @($aulas | Where-Object { $_.data -eq $hoje })
$temOutras = ($aulas.Count -gt $doDia.Count) -or ($sugestoes.Count -gt 0)

$aula = $null
if ($doDia.Count -eq 1 -and ($Data -or -not $temOutras)) {
    # Data pedida no parâmetro, ou nada mais para escolher: abre direto
    $aula = $doDia[0]
}

$tela = if ($doDia.Count -gt 0) { "hoje" } else { "todas" }
while (-not $aula) {
    if ($tela -eq "hoje") {
        $r = Select-AulaDoDia $doDia $temOutras
        if ($r -eq "O") { $tela = "todas"; continue }
        if ($r -eq "V") { return }
        $aula = $r
    } else {
        $titulo = if ($doDia.Count -gt 0) { "Todas as aulas:" } else { "Nenhuma aula cadastrada para hoje. Últimas aulas:" }
        $r = Select-Aula $titulo $aulas $sugestoes
        if ($r -eq "S") {
            Show-LinksMenu "$($dados.nome) — Sugestões ainda não usadas" $sugestoes
            if ($global:IRM_AmbientePronto) { return }
            continue
        }
        if ($r -eq "V") {
            if ($doDia.Count -eq 0) { return }
            $tela = "hoje"
            continue
        }
        $aula = $r
    }
}

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
