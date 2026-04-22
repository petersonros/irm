Write-Host "🚀 Abrindo URLs da aula..." -ForegroundColor Cyan

# URLs da aula
$urls = @(
    "https://wordwall.net/pt/resource/18749562/quebra-cabe%C3%A7a-animais-dom%C3%A9sticos",
    "https://www.digipuzzle.net/digipuzzle/kids/puzzles/linkpuzzle_alphabet_pt.htm?language=portuguese&linkback=../../../pt/jogoseducativos/alfabeto/index.htm",
    "https://www.digipuzzle.net/digipuzzle/kids/puzzles/linkpuzzle_animals_shadows.htm?language=portuguese&linkback=../../../pt/jogoseducativos/infantil/index.htm",
    "https://wordwall.net/pt/resource/54499719/formas-geom%C3%A9tricas"
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
