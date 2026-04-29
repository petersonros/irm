Write-Host "🚀 Abrindo URLs da aula — Infantil 4..." -ForegroundColor Cyan

# URLs da aula — Infantil 4
$urls = @(
    "https://wordwall.net/pt/resource/25820616/jogo-da-mem%C3%B3ria-animais",
    "https://wordwall.net/pt/resource/17128941/jogo-da-mem%C3%B3ria-dinossauro",
    "https://wordwall.net/pt/resource/17070730/percep%C3%A7%C3%A3o-e-mem%C3%B3ria/jogo-da-mem%C3%B3ria-s%C3%ADtio-do",
    "https://wordwall.net/pt/resource/4044063/jogo-da-mem%C3%B3ria-animais",
    "https://wordwall.net/pt/resource/32416546/educa%C3%A7%C3%A3o-e-treinamento/jogos-da-mem%C3%B3ria-animais"
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
