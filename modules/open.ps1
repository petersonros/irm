Write-Host "🚀 Abrindo URLs da aula..." -ForegroundColor Cyan

# URLs da aula
$urls = @(
    # 03-09-2026 (Mariana 5 ano B)
    #"https://canva.link/g3mmon84gw06myl",
    #"https://wordwall.net/pt/resource/12879527/sistema-digest%C3%B3rio",
    #"https://wordwall.net/pt/resource/4132309/sistema-digest%C3%B3rio"

    # 17-09-2026 (Mariana 5 ano B)
    "https://wordwall.net/pt/resource/3327204/sistema-respirat%C3%B3rio",
    "https://wordwall.net/pt/resource/6663282/sistema-respirat%C3%B3rio"
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
