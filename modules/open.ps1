Write-Host "🚀 Abrindo URLs da aula..." -ForegroundColor Cyan

# URLs da aula
$urls = @(
    "https://www.digipuzzle.net/digipuzzle/kids/puzzles/phototurn.htm?language=portuguese&linkback=../../../pt/jogoseducativos/infantil/index.htm#google_vignette",
    "https://www.digipuzzle.net/minigames/snake/snake_additions_zero_to_ten.htm?language=portuguese&linkback=../../pt/jogoseducativos/matematica-ate-10/index.htm",
    "https://www.digipuzzle.net/kids/animalcartoons/puzzles/lines_math_till_ten.htm?language=portuguese&linkback=../../../pt/jogoseducativos/matematica-ate-10/index.htm",
    "https://wordwall.net/pt/resource/54499719/formas-geom%C3%A9tricas",
    "https://wordwall.net/pt/resource/3680303/jogo-das-vogais"
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
