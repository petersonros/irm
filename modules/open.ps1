# URLs da aula
# Cada item pode ser só a URL ou "Rótulo | URL" (o rótulo aparece no submenu)
$urls = @(
    # 03-09-2026 (Mariana 5 ano B)
    # "https://canva.link/g3mmon84gw06myl",
    # "https://wordwall.net/pt/resource/12879527/sistema-digest%C3%B3rio",
    # "https://wordwall.net/pt/resource/4132309/sistema-digest%C3%B3rio",

    # 17-09-2026 (Mariana 5 ano B)
    #"https://wordwall.net/pt/resource/3327204/sistema-respirat%C3%B3rio",
    #"https://wordwall.net/pt/resource/6663282/sistema-respirat%C3%B3rio"

    # 18-09-2026 (Valeria 4 ano A)
    #"https://wordwall.net/pt/resource/58283470/fra%C3%A7%C3%B5es-equivalentes-4%C2%BA-ano",
    #"https://wordwall.net/pt/resource/21796051/fra%C3%A7%C3%A3o-4%C2%BA-ano",
    #"https://wordwall.net/resource/100202594/matem%C3%A1tica/fra%C3%A7%C3%B5es-equivalentes-4-ano",
    #"https://wordwall.net/pt/resource/101360367/fra%C3%A7%C3%B5es-equivalentes-4%C2%BA-ano",
    #"https://wordwall.net/pt/resource/35993201/fra%C3%A7%C3%A3o-equivalente-4%C2%BA-ano"

    # 19-09-2026 (Geovana 5 ano D)
    # "https://wordwall.net/pt/resource/3327204/sistema-respirat%C3%B3rio",
    # "https://wordwall.net/pt/resource/6663282/sistema-respirat%C3%B3rio"

    # 01-10-2026 (Mariana 5 ano B)
    # "https://wordwall.net/pt/resource/12131645/5ano-sistema-cardiovascular",
    # "https://wordwall.net/pt/resource/113054138/sistema-cardiovascular"

    # 30-10-2026 (Valeria 4 ano A)
    # "https://www.escolagames.com.br/jogos/area-na-malha",
    # "https://wordwall.net/pt/resource/13375400/%C3%A1rea-e-per%C3%ADmetro-2",
    # "https://wordwall.net/pt/resource/5554007/%C3%A1rea-e-per%C3%ADmetro",
    # "https://wordwall.net/pt/resource/14049177/%C3%A1rea-e-per%C3%ADmetro-4%C2%BA-ano",
    # "https://wordwall.net/pt/resource/16134834/per%C3%ADmetro-%C3%A1rea-e-volume",
    # "https://wordwall.net/pt/resource/24494762/%C3%A1rea-e-per%C3%ADmetro"
    # "https://phet.colorado.edu/sims/html/area-model-introduction/latest/area-model-introduction_all.html?locale=pt_BR"

    # 2026-11-03 Viviam
    "Pesquisa de Satisfação — 6º ano — Manhã | https://forms.gle/ruQjDHdSsyxN72cN7",
    "Pesquisa de Satisfação — 6º ano — Tarde | https://forms.gle/SCCteGorax3ANu8w7",
    "Pesquisa de Satisfação — 7º ano — Manhã | https://forms.gle/t8MmqwWKxwUp6uq9A",
    "Pesquisa de Satisfação — 7º ano — Tarde | https://forms.gle/Cd9tnQJztPY3cPKr8",
    "Pesquisa de Satisfação — 8º ano — Manhã | https://forms.gle/P3PPTyfhvp3ZMG5Z9",
    "Pesquisa de Satisfação — 8º ano — Tarde | https://forms.gle/KYm6AZHnvGmoVkR58",
    "Pesquisa de Satisfação — | https://petersonros.github.io/irm/pages/viviam.html"
    
)

# Separar rótulo e URL ("Rótulo | URL" ou só "URL")
$links = @(foreach ($item in $urls) {
    $parts = $item -split '\s*\|\s*', 2
    if ($parts.Count -eq 2) {
        [PSCustomObject]@{ Label = $parts[0]; Url = $parts[1]; Opened = $false }
    } else {
        [PSCustomObject]@{ Label = $item; Url = $item; Opened = $false }
    }
})

if ($links.Count -eq 0) {
    Write-Host "Nenhuma URL ativa na lista." -ForegroundColor Yellow
    return
}

# Detectar navegador
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

# Comportamento original: fecha o navegador e abre todas na mesma janela, em ordem
function Open-AllUrls {
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

function Show-OpenMenu {
    Clear-Host
    Write-Host ""
    Write-Host "  ==== URLs da Pesquisa ====" -ForegroundColor Cyan
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
}

# =========================
# SUBMENU
# =========================
while ($true) {
    Show-OpenMenu
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
        Write-Host "🚀 Abrindo todas as URLs da aula..." -ForegroundColor Cyan
        Open-AllUrls
        foreach ($link in $links) { $link.Opened = $true }
        Write-Host "✅ Ambiente pronto!"
        Start-Sleep -Seconds 1
    }
    elseif ($choice -match '^[Vv]$') {
        break
    }
}
