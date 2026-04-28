Write-Host "🚀 Abrindo URLs da aula..." -ForegroundColor Cyan

# URLs da aula
$urls = @(
    "https://www.digipuzzle.net/kids/backtoschool/puzzles/hiddenicons.htm?language=english&linkback=../../../main/kids/index.htm#google_vignette",
    "https://www.digipuzzle.net/digipuzzle/kids/puzzles/puzzle_photocircle.htm?language=english&linkback=../../../main/kids/index.htm#google_vignette",
    "https://www.digipuzzle.net/minigames/dices/dices_count.htm?language=english&linkback=../../education/kindergarten/index.htm",
    "https://www.digipuzzle.net/digipuzzle/kids/puzzles/puzzle_clutter.htm?language=english&https://www.digipuzzle.net/digipuzzle/kids/puzzles/puzzle_clutter.htm?language=english&linkback=../../../main/kids/index.htm#google_vignette/../main/kids/index.htm#google_vignette"
)

# Detectar navegador
if (Get-Command chrome.exe -ErrorAction SilentlyContinue) {
    $browser     = "chrome.exe"
    $processName = "chrome"
} elseif (Get-Command msedge.exe -ErrorAction SilentlyContinue) {
    $browser     = "msedge.exe"
    $processName = "msedge"
} else {
    foreach ($url in $urls) {
        Start-Process $url
    }
    Write-Host "✅ Ambiente pronto!"
    exit
}

# Encerrar o navegador se já estiver aberto (garante --new-window limpo)
if (Get-Process -Name $processName -ErrorAction SilentlyContinue) {
    Write-Host "   Navegador aberto detectado — encerrando antes de abrir..." -ForegroundColor DarkYellow
    Stop-Process -Name $processName -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

# Abrir todas as URLs na mesma janela
Start-Process $browser ("--new-window " + ($urls -join " "))

Write-Host "✅ Ambiente pronto!"
