Write-Host "🚀 Abrindo URLs da aula — Infantil 5..." -ForegroundColor Cyan

# URLs da aula — Infantil 5
$urls = @(
    "https://wordwall.net/pt/resource/29367152/alfabetiza%C3%A7%C3%A3o",
    "https://wordwall.net/pt/resource/11335506/alfabetiza%C3%A7%C3%A3o",
    "https://wordwall.net/pt/resource/4833187/alfabetiza%C3%A7%C3%A3o",
    "https://wordwall.net/pt/resource/11088487/alfabetiza%C3%A7%C3%A3o"
)

# Detectar navegador
if (Get-Command chrome.exe -ErrorAction SilentlyContinue) {
    $browser = "chrome.exe"
    $processName = "chrome"
}
elseif (Get-Command msedge.exe -ErrorAction SilentlyContinue) {
    $browser = "msedge.exe"
    $processName = "msedge"
}
else {
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
