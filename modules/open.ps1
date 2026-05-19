Write-Host "🚀 Abrindo URLs da aula..." -ForegroundColor Cyan

# URLs da aula
$urls = @(
    "https://wordwall.net/pt/resource/34757094/ler-palavras-silabas-simples",
    "https://wordwall.net/pt/resource/5503948/vogais",
    "https://wordwall.net/pt/resource/73160047/comunica%C3%A7%C3%A3o/alfamatchza%C3%A7%C3%A3o",
    "https://wordwall.net/pt/resource/2867409/alfabetiza%C3%A7%C3%A3o/vogais-e-consoantes",
    "https://wordwall.net/pt/resource/17053394/jogo-alfabetiza%C3%A7%C3%A3o",
    "https://wordwall.net/pt/resource/5114866/alfabetiza%C3%A7%C3%A3o"
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
