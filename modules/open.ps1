Write-Host "🚀 Abrindo URLs da aula..." -ForegroundColor Cyan

# URLs da aula
$urls = @(
    "https://wordwall.net/pt/resource/19436189/jogo-dos-n%C3%BAmeros",
    "https://wordwall.net/pt/resource/3680303/jogo-das-vogais",
    "https://wordwall.net/pt/resource/16859260/n%C3%BAmeros/jogo-da-mem%C3%B3ria-de-n%C3%BAmeros",
    "https://wordwall.net/pt/resource/21497625/frutas-e-verduras/jogo-da-mem%C3%B3ria-frutas-e-legumes",
    "https://wordwall.net/pt/resource/11411697/jogo-das-vogais"
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
