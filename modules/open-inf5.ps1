Write-Host "🚀 Abrindo URLs da aula — Infantil 5..." -ForegroundColor Cyan

# URLs da aula — Infantil 5
$urls = @(
    "https://wordwall.net/pt/resource/5421540/jogo-da-mem%C3%B3ria-meios-de-comunica%C3%A7%C3%A3o",
    "https://wordwall.net/pt/resource/33354360/rimas/jogo-do-rimas",
    "https://wordwall.net/pt/resource/89539742/jogo-da-mem%C3%B3ria-dos-n%C3%BAmeros-at%C3%A9-30",
    "https://wordwall.net/pt/resource/23501070/mathematics/1%C2%BA-ano-complete-a-sequ%C3%AAncia-num%C3%A9rica-de-0-at%C3%A9-30",
    "https://wordwall.net/pt/resource/53581478/vamos-organizar-o-alfabeto"
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
