Write-Host "🚀 Abrindo URLs da aula..." -ForegroundColor Cyan

# URLs da aula
$urls = @(
    "https://www.digipuzzle.net/digipuzzle/kids/puzzles/letterbattle_pt.htm?language=portuguese&linkback=../../../pt/jogoseducativos/alfabeto/index.htm",
    "https://www.digipuzzle.net/digipuzzle/animals/puzzles/clutter.htm?language=portuguese&linkback=../../../pt/jogoseducativos/jogos/index.htm"
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
